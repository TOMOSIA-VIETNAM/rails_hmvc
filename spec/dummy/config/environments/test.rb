# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Rails 7.2+ renamed cache_classes to enable_reloading
  if Rails::VERSION::MAJOR >= 8 || (Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR >= 2)
    config.enable_reloading = false
  else
    config.cache_classes = true
  end

  config.eager_load = false
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=3600" }
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # show_exceptions accepts :rescuable symbol from Rails 7.1+
  if Rails::VERSION::MAJOR > 7 || (Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR >= 1)
    config.action_dispatch.show_exceptions = :rescuable
  else
    config.action_dispatch.show_exceptions = true
  end

  config.action_controller.allow_forgery_protection = false
  config.active_support.deprecation = :stderr
  config.active_record.migration_error = :page_load
  config.secret_key_base = "0" * 32

  # active_storage may not be loaded in all configurations
  config.active_storage.service = :test if config.respond_to?(:active_storage)
end
