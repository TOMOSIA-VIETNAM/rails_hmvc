# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require 'rails_hmvc/cop/forms/no_database_interaction'

RSpec.describe RuboCop::Cop::RailsHmvc::Forms::NoDatabaseInteraction, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when in a form file' do
    before do
      allow_any_instance_of(described_class).to receive(:form_file?)
        .and_return(true)
    end

    it 'registers an offense for direct model creation' do
      expect_offense(<<~RUBY)
        class CreateUserForm < ApplicationForm
          def save
            User.create!(attributes)
            ^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
          end
        end
      RUBY
    end

    it 'registers an offense for model queries' do
      expect_offense(<<~RUBY)
        class UserForm < ApplicationForm
          def user_exists?
            User.exists?(email: email)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
          end
        end
      RUBY
    end

    it 'registers an offense for database transactions' do
      expect_offense(<<~RUBY)
        class UpdateUserForm < ApplicationForm
          def save
            User.transaction do
            ^^^^^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
              user.save!
            end
          end
        end
      RUBY
    end

    it 'registers an offense for direct connection usage' do
      expect_offense(<<~RUBY)
        class ImportForm < ApplicationForm
          def import
            ActiveRecord::Base.connection.execute("SELECT * FROM users")
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
          end
        end
      RUBY
    end

    it 'does not register an offense for validations' do
      expect_no_offenses(<<~RUBY)
        class CreateUserForm < ApplicationForm
          attribute :email, :string
          attribute :name, :string

          validates :email, presence: true
          validates :name, length: { minimum: 2 }

          def valid!
            raise Error, errors.to_json unless valid?
          end
        end
      RUBY
    end

    it 'registers an offense for complex model queries' do
      expect_offense(<<~RUBY)
        class SearchUserForm < ApplicationForm
          def search
            User.where(active: true)
            ^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
              .includes(:posts)
              .order(created_at: :desc)
          end
        end
      RUBY
    end
  end

  context 'when not in a form file' do
    before do
      allow_any_instance_of(described_class).to receive(:form_file?)
        .and_return(false)
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class CreateUserForm < ApplicationForm
          def save
            User.create!(attributes)
          end
        end
      RUBY
    end
  end

  describe 'model detection' do
    before do
      allow_any_instance_of(described_class).to receive(:form_file?)
        .and_return(true)
    end

    it 'identifies standard model names' do
      expect_offense(<<~RUBY)
        class Form < ApplicationForm
          def process
            User.find(1)
            ^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
            Product.first
            ^^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
            Order.last
            ^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
          end
        end
      RUBY
    end

    it 'identifies custom model names' do
      expect_offense(<<~RUBY)
        class Form < ApplicationForm
          def process
            CustomModel.create!(data)
            ^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
          end
        end
      RUBY
    end
  end

  describe 'database method detection' do
    before do
      allow_any_instance_of(described_class).to receive(:form_file?)
        .and_return(true)
    end

    it 'detects various database operations' do
      expect_offense(<<~RUBY)
        class Form < ApplicationForm
          def process
            Model.find_by(email: email)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
            Model.delete_all
            ^^^^^^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
            Model.count
            ^^^^^^^^^^^ RailsHmvc/Forms/NoDatabaseInteraction: Form classes should not interact directly with database. Move database operations to Operations.
          end
        end
      RUBY
    end
  end
end
