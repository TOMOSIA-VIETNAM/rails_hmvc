# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Forms
        # Ensures that Form files follow RESTful naming conventions
        #
        # @example
        #   # bad - non-RESTful action name
        #   app/forms/users/process_user_form.rb
        #   app/forms/users/handle_data_form.rb
        #
        #   # good - RESTful action names
        #   app/forms/users/create_form.rb
        #   app/forms/users/update_form.rb
        #   app/forms/users/new_form.rb
        #   app/forms/users/edit_form.rb
        class RestfulNaming < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Form file should use RESTful action names: %<suggestions>s'

          RESTFUL_ACTIONS = %w[
            new edit create update
          ].freeze

          NON_RESTFUL_PATTERNS = {
            /process_/ => 'create',
            /handle_/ => 'update',
            /manage_/ => 'update',
            /save_/ => 'create',
            /store_/ => 'create',
            /add_/ => 'create',
            /modify_/ => 'update',
            /change_/ => 'update'
          }.freeze

          def on_new_investigation
            file_path = processed_source.file_path
            return unless form_file?(file_path)

            filename = File.basename(file_path, '.rb')
            return unless filename.end_with?('_form')

            action_name = filename.sub('_form', '')
            return if RESTFUL_ACTIONS.include?(action_name)

            suggestions = suggest_restful_actions(action_name)
            return if suggestions.empty?

            add_global_offense(
              format(MSG, suggestions: suggestions.join(', ')),
              severity: :warning
            )
          end

          private

          def form_file?(file_path)
            file_path.match?(%r{/forms/.*_form\.rb$})
          end

          def suggest_restful_actions(action_name)
            suggestions = []

            NON_RESTFUL_PATTERNS.each do |pattern, suggestion|
              if action_name.match?(pattern)
                suggestions << suggestion
              end
            end

            # If no pattern matches, suggest common form actions
            if suggestions.empty?
              suggestions = %w[create update new edit]
            end

            suggestions.uniq
          end
        end
      end
    end
  end
end
