# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require 'rails_hmvc/cop/controllers/delegate_to_operations'

RSpec.describe RuboCop::Cop::RailsHmvc::Controllers::DelegateToOperations, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when in a controller file' do
    before do
      allow_any_instance_of(described_class).to receive(:controller_file?)
        .and_return(true)
    end

    it 'registers an offense for business logic in create action' do
      expect_offense(<<~RUBY)
        class UsersController < ApplicationController
          def create
          ^^^^^^^^^^ RailsHmvc/Controllers/DelegateToOperations: Controller actions should delegate to Operations for business logic
            user = User.create!(user_params)
            render json: user
          end
        end
      RUBY
    end

    it 'registers an offense for business logic in update action' do
      expect_offense(<<~RUBY)
        class UsersController < ApplicationController
          def update
          ^^^^^^^^^^ RailsHmvc/Controllers/DelegateToOperations: Controller actions should delegate to Operations for business logic
            user = User.find(params[:id])
            user.update!(user_params)
            render json: user
          end
        end
      RUBY
    end

    it 'does not register an offense for simple render' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          def index
            render :index
          end
        end
      RUBY
    end

    it 'does not register an offense when using operation' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          def create
            operator = User::CreateOperation.call(params: user_params)
            render json: operator.result
          end
        end
      RUBY
    end

    it 'does not register an offense for multiple simple renders' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          def show
            render :show
            head :ok
            redirect_to root_path
          end
        end
      RUBY
    end

    it 'does not register an offense for operation with instance variable' do
      expect_no_offenses(<<~RUBY)
        class UsersController < ApplicationController
          def update
            @operator = User::UpdateOperation.call(params: user_params)
            render json: @operator.result
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
            user = User.create!(user_params)
            render json: user
          end
        end
      RUBY
    end
  end
end
