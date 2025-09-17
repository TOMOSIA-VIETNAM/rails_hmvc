# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require 'rails_hmvc/cop/operations/business_logic_only'

RSpec.describe RuboCop::Cop::RailsHmvc::Operations::BusinessLogicOnly, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when in an operation file' do
    before do
      allow_any_instance_of(described_class).to receive(:operation_file?)
        .and_return(true)
    end

    it 'registers an offense for direct model creation in call method' do
      expect_offense(<<~RUBY)
        class CreateUserOperation < ApplicationOperation
          def call
            User.create!(params)
            ^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Operations/BusinessLogicOnly: Operations should not contain direct model calls in `call` method. Use step methods instead.
          end
        end
      RUBY
    end

    it 'registers an offense for direct model queries in call method' do
      expect_offense(<<~RUBY)
        class FindUserOperation < ApplicationOperation
          def call
            User.find_by(email: params[:email])
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Operations/BusinessLogicOnly: Operations should not contain direct model calls in `call` method. Use step methods instead.
            Product.where(active: true)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Operations/BusinessLogicOnly: Operations should not contain direct model calls in `call` method. Use step methods instead.
          end
        end
      RUBY
    end

    it 'does not register an offense for model calls in step methods' do
      expect_no_offenses(<<~RUBY)
        class CreateUserOperation < ApplicationOperation
          def call
            step_validate
            step_create_user
          end

          private

          def step_create_user
            User.create!(user_params)
          end

          def step_validate
            User.exists?(email: params[:email])
          end
        end
      RUBY
    end

    it 'does not register an offense for non-model method calls in call' do
      expect_no_offenses(<<~RUBY)
        class ProcessUserOperation < ApplicationOperation
          def call
            validate_params
            process_data
            notify_user
          end
        end
      RUBY
    end

    it 'registers an offense for multiple model calls' do
      expect_offense(<<~RUBY)
        class ComplexOperation < ApplicationOperation
          def call
            User.find(params[:id])
            ^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Operations/BusinessLogicOnly: Operations should not contain direct model calls in `call` method. Use step methods instead.
            Order.create!(order_params)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Operations/BusinessLogicOnly: Operations should not contain direct model calls in `call` method. Use step methods instead.
            Product.update_all(status: 'active')
          end
        end
      RUBY
    end
  end

  context 'when not in an operation file' do
    before do
      allow_any_instance_of(described_class).to receive(:operation_file?)
        .and_return(false)
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class CreateUserOperation < ApplicationOperation
          def call
            User.create!(params)
            Product.find(1)
          end
        end
      RUBY
    end
  end

  describe 'model detection' do
    before do
      allow_any_instance_of(described_class).to receive(:operation_file?)
        .and_return(true)
    end

    it 'identifies standard model names' do
      expect_offense(<<~RUBY)
        class Operation < ApplicationOperation
          def call
            User.first
            ^^^^^^^^^^ RailsHmvc/Operations/BusinessLogicOnly: Operations should not contain direct model calls in `call` method. Use step methods instead.
            Product.last
            ^^^^^^^^^^^^ RailsHmvc/Operations/BusinessLogicOnly: Operations should not contain direct model calls in `call` method. Use step methods instead.
            Order.all
            ^^^^^^^^^ RailsHmvc/Operations/BusinessLogicOnly: Operations should not contain direct model calls in `call` method. Use step methods instead.
          end
        end
      RUBY
    end

    it 'identifies custom model names' do
      expect_offense(<<~RUBY)
        class Operation < ApplicationOperation
          def call
            CustomModel.create!(data)
            ^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Operations/BusinessLogicOnly: Operations should not contain direct model calls in `call` method. Use step methods instead.
          end
        end
      RUBY
    end
  end
end
