# frozen_string_literal: true

require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require 'rails_hmvc/cop/models/concerns_location'

RSpec.describe RuboCop::Cop::RailsHmvc::Models::ConcernsLocation, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when in a model file' do
    before do
      allow_any_instance_of(described_class).to receive(:model_file?)
        .and_return(true)
    end

    it 'registers an offense for complex methods' do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
          def complex_title_formatting
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RailsHmvc/Models/ConcernsLocation: Complex model methods should be extracted to concerns. Method `complex_title_formatting` has 6 lines.
            title = get_title
            title = title.upcase
            title = title.gsub('-', ' ')
            title = apply_special_formatting(title)
            title = add_prefix(title)
            title
          end
        end
      RUBY
    end

    it 'registers an offense for multiple complex methods' do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
          def method1
          ^^^^^^^^^^^ RailsHmvc/Models/ConcernsLocation: Complex model methods should be extracted to concerns. Method `method1` has 6 lines.
            line1
            line2
            line3
            line4
            line5
            line6
          end

          def method2
          ^^^^^^^^^^^ RailsHmvc/Models/ConcernsLocation: Complex model methods should be extracted to concerns. Method `method2` has 6 lines.
            line1
            line2
            line3
            line4
            line5
            line6
          end
        end
      RUBY
    end

    it 'does not register an offense for simple methods' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          def full_name
            "\#{first_name} \#{last_name}"
          end

          def active?
            status == 'active'
          end

          def to_s
            email
          end
        end
      RUBY
    end

    it 'does not register an offense for Rails DSL methods' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          validates :email, presence: true
          validates_length_of :name, minimum: 2
          
          belongs_to :organization
          has_many :posts
          
          scope :active, -> { where(active: true) }
          
          enum status: %i[pending active inactive]
          
          delegate :name, to: :organization, prefix: true
        end
      RUBY
    end

    it 'registers an offense for too many methods' do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
              ^^^^ RailsHmvc/Models/ConcernsLocation: Model has 9 custom methods. Consider extracting some to concerns.
          def method1; end
          def method2; end
          def method3; end
          def method4; end
          def method5; end
          def method6; end
          def method7; end
          def method8; end
          def method9; end
        end
      RUBY
    end

    it 'does not count private helper methods starting with underscore' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          def public_method
            _private_helper1
            _private_helper2
          end

          private

          def _private_helper1
            # Complex logic here
            do_something
            process_data
            handle_edge_cases
          end

          def _private_helper2
            # More complex logic
            transform_data
            validate_result
            format_output
          end
        end
      RUBY
    end
  end

  context 'when in a concern file' do
    before do
      allow_any_instance_of(described_class).to receive(:model_file?)
        .and_return(false)
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          def complex_method
            do_something
            process_data
            handle_edge_cases
            transform_data
            validate_result
            format_output
          end
        end
      RUBY
    end
  end

  describe 'method line counting' do
    before do
      allow_any_instance_of(described_class).to receive(:model_file?)
        .and_return(true)
    end

    it 'counts actual lines in method body' do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
          def complex_process
          ^^^^^^^^^^^^^^^^^^^ RailsHmvc/Models/ConcernsLocation: Complex model methods should be extracted to concerns. Method `complex_process` has 6 lines.
            step1
            step2
            step3
            step4
            step5
            result
          end
        end
      RUBY
    end

    it 'handles single-line methods correctly' do
      expect_no_offenses(<<~RUBY)
        class User < ApplicationRecord
          def simple_method; 'result'; end
          def one_liner; do_something end
        end
      RUBY
    end
  end
end
