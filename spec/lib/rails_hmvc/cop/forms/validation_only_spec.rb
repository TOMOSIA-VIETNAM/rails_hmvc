# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require 'rails_hmvc/cop/forms/validation_only'

RSpec.describe RuboCop::Cop::RailsHmvc::Forms::ValidationOnly, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when in a form file' do
    before do
      allow_any_instance_of(described_class).to receive(:form_file?)
        .and_return(true)
    end

    it 'registers an offense for ActiveRecord associations' do
      expect_offense(<<~RUBY)
        class UserForm < ApplicationForm
          has_one :profile
          ^^^^^^^^^^^^^^^^ RailsHmvc/Forms/ValidationOnly: Form classes should only contain validation logic. Move has_one to model or concern.
          belongs_to :organization
          ^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/ValidationOnly: Form classes should only contain validation logic. Move belongs_to to model or concern.
          has_many :posts
          ^^^^^^^^^^^^^^^ RailsHmvc/Forms/ValidationOnly: Form classes should only contain validation logic. Move has_many to model or concern.
        end
      RUBY
    end

    it 'registers an offense for scopes and delegates' do
      expect_offense(<<~RUBY)
        class UserForm < ApplicationForm
          scope :active, -> { where(active: true) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/ValidationOnly: Form classes should only contain validation logic. Move scope to model or concern.
          delegate :name, to: :user
          ^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/ValidationOnly: Form classes should only contain validation logic. Move delegate to model or concern.
        end
      RUBY
    end

    it 'registers an offense for callbacks' do
      expect_offense(<<~RUBY)
        class UserForm < ApplicationForm
          before_save :process_data
          ^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/ValidationOnly: Form classes should only contain validation logic. Move before_save to model or concern.
          after_create :send_welcome_email
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/ValidationOnly: Form classes should only contain validation logic. Move after_create to model or concern.
        end
      RUBY
    end

    it 'registers an offense for custom methods' do
      expect_offense(<<~RUBY)
        class UserForm < ApplicationForm
          def process_data
          ^^^^^^^^^^^^^^^^ RailsHmvc/Forms/ValidationOnly: Form classes should only contain validation logic. Move process_data to model or concern.
            # Some processing
          end

          def calculate_total
          ^^^^^^^^^^^^^^^^^^^ RailsHmvc/Forms/ValidationOnly: Form classes should only contain validation logic. Move calculate_total to model or concern.
            # Some calculation
          end
        end
      RUBY
    end

    it 'does not register an offense for error handling methods' do
      expect_no_offenses(<<~RUBY)
        class UserForm < ApplicationForm
          def error_messages
            errors.full_messages.join(', ')
          end

          def invalid?
            !valid?
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
        class UserForm < ApplicationForm
          has_many :posts
          scope :active, -> { where(active: true) }
          
          def process_data
            # Some processing
          end
        end
      RUBY
    end
  end

  describe 'allowed form methods' do
    before do
      allow_any_instance_of(described_class).to receive(:form_file?)
        .and_return(true)
    end

    it 'allows validation-related method names' do
      expect_no_offenses(<<~RUBY)
        class UserForm < ApplicationForm
          def valid_email?
            email.present? && email.include?('@')
          end

          def validate_password_strength
            errors.add(:password, 'too weak') if password.length < 8
          end
        end
      RUBY
    end
  end
end
