# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsHmvc
      module Operations
        # Ensures that Operation files follow RESTful naming conventions
        #
        # @example
        #   # bad - non-RESTful action name
        #   app/operations/users/process_user_operation.rb
        #   app/operations/users/handle_data_operation.rb
        #
        #   # good - RESTful action names
        #   app/operations/users/index_operation.rb
        #   app/operations/users/show_operation.rb
        #   app/operations/users/create_operation.rb
        #   app/operations/users/update_operation.rb
        #   app/operations/users/destroy_operation.rb
        #   app/operations/users/new_operation.rb
        #   app/operations/users/edit_operation.rb
        class RestfulNaming < RuboCop::Cop::Base
          extend AutoCorrector

          MSG = 'Operation file should use RESTful action names: %<suggestions>s'

          RESTFUL_ACTIONS = %w[
            index show new edit create update destroy
          ].freeze

          NON_RESTFUL_PATTERNS = {
            /process_/ => 'create',
            /handle_/ => 'update',
            /manage_/ => 'update',
            /delete_/ => 'destroy',
            /remove_/ => 'destroy',
            /add_/ => 'create',
            /get_/ => 'show',
            /list_/ => 'index',
            /fetch_/ => 'show',
            /save_/ => 'create',
            /store_/ => 'create'
          }.freeze

          def on_new_investigation
            file_path = processed_source.file_path
            return unless operation_file?(file_path)

            filename = File.basename(file_path, '.rb')
            return unless filename.end_with?('_operation')

            action_name = filename.sub('_operation', '')
            return if RESTFUL_ACTIONS.include?(action_name)

            suggestions = suggest_restful_actions(action_name)
            return if suggestions.empty?

            add_global_offense(
              message: format(MSG, suggestions: suggestions.join(', ')),
              severity: :warning
            )
          end

          private

          def operation_file?(file_path)
            file_path.match?(%r{/operations/.*_operation\.rb$})
          end

          def suggest_restful_actions(action_name)
            suggestions = []

            NON_RESTFUL_PATTERNS.each do |pattern, suggestion|
              if action_name.match?(pattern)
                suggestions << suggestion
              end
            end

            # If no pattern matches, suggest common RESTful actions
            if suggestions.empty?
              suggestions = %w[create update show destroy]
            end

            suggestions.uniq
          end
        end
      end
    end
  end
end
