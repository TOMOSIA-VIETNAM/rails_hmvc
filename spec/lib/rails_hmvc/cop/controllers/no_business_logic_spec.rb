# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require 'rails_hmvc/cop/controllers/no_business_logic'

RSpec.describe RuboCop::Cop::RailsHmvc::Controllers::NoBusinessLogic, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when in a controller file' do
    before do
      allow_any_instance_of(described_class).to receive(:controller_file?)
        .and_return(true)
    end

    it 'does not register an offense for simple renders' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          def index
            render :index
          end
        end
      RUBY
    end

    it 'does not register an offense for simple success checks' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          def create
            if operator.success?
              render json: operator.result
            else
              render json: { errors: operator.errors }
            end
          end
        end
      RUBY
    end

    it 'does not register an offense for permitted controller methods' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          before_action :authenticate_user!
          
          def create
            authorize User
            render json: User.find(params[:id])
          end

          private

          def user_params
            params.require(:user).permit(:name, :email)
          end
        end
      RUBY
    end
  end

  context 'when not in a controller file' do
    before do
      allow_any_instance_of(described_class).to receive(:controller_file?)
        .and_return(false)
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          def create
            user.name = user.name.titleize
            user.save!
          end
        end
      RUBY
    end
  end

  describe 'complex business logic detection' do
    before do
      allow_any_instance_of(described_class).to receive(:controller_file?)
        .and_return(true)
    end
  end
end
