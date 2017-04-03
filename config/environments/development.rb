SEEK::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  #This can be very useful in development when you have code that interacts directly with Rails.cache,
  #but caching may interfere with being able to see the results of code changes.
  #config.cache_store = :null_store
  config.action_controller.cache_store = [:file_store, "#{Rails.root}/tmp/dev-cache"]
  config.cache_store = [:file_store, "#{Rails.root}/tmp/dev-cache"]

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  config.assets.debug = true

  config.serve_static_assets = true

  I18n.enforce_available_locales = true
end
