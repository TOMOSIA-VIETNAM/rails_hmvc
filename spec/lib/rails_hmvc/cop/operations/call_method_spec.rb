# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require 'rails_hmvc/cop/operations/call_method'

RSpec.describe RuboCop::Cop::RailsHmvc::Operations::CallMethod, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when in an operation file' do
    before do
      allow_any_instance_of(described_class).to receive(:operation_file?)
        .and_return(true)
    end

    it 'registers an offense when call method is missing' do
      expect_offense(<<~RUBY)
        class CreateUserOperation < ApplicationOperation
              ^^^^^^^^^^^^^^^^^^^ RailsHmvc/Operations/CallMethod: Operation classes must have a `call` method
          def execute
            # business logic
          end
        end
      RUBY
    end

    it 'does not register an offense when call method exists' do
      expect_no_offenses(<<~RUBY)
        class CreateUserOperation < ApplicationOperation
          def call
            # business logic
          end
        end
      RUBY
    end

    it 'does not register an offense when call method exists with other methods' do
      expect_no_offenses(<<~RUBY)
        class ComplexOperation < ApplicationOperation
          def call
            step_one
            step_two
          end

          private

          def step_one
            # some logic
          end

          def step_two
            # more logic
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

    it 'does not register an offense when call method is missing' do
      expect_no_offenses(<<~RUBY)
        class SomeClass < ApplicationOperation
          def execute
            # some logic
          end
        end
      RUBY
    end
  end

  context 'with different class structures' do
    before do
      allow_any_instance_of(described_class).to receive(:operation_file?)
        .and_return(true)
    end

    it 'handles nested classes correctly' do
      expect_offense(<<~RUBY)
        module Operations
          class CreateUser < ApplicationOperation
                ^^^^^^^^^^ RailsHmvc/Operations/CallMethod: Operation classes must have a `call` method
            def process
              # business logic
            end
          end
        end
      RUBY
    end

    it 'handles class with multiple method definitions' do
      expect_no_offenses(<<~RUBY)
        class MultiMethodOperation < ApplicationOperation
          def initialize(params)
            @params = params
          end

          def call
            # business logic
          end

          def success?
            @success
          end
        end
      RUBY
    end
  end
end
