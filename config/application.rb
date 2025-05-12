require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TestActiveAdmin
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Log des variables d'environnement au démarrage
    # config.after_initialize do
    #   Rails.logger.info "Facebook ENV variables check:"
    #   Rails.logger.info "APP_ID present: #{ENV['FACEBOOK_APP_ID'].present?}"
    #   Rails.logger.info "APP_SECRET present: #{ENV['FACEBOOK_APP_SECRET'].present?}"
    #   Rails.logger.info "ACCESS_TOKEN present: #{ENV['FACEBOOK_ACCESS_TOKEN'].present?}"
    #   Rails.logger.info "CAMPAIGN_ID present: #{ENV['FACEBOOK_CAMPAIGN_ID'].present?}"
    # end

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
