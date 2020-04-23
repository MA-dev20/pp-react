require_relative 'boot'
require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module Peterpitch
  class Application < Rails::Application

    config.active_job.queue_adapter = :delayed_job
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.autoload_paths += %W(#{config.root}/lib)
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.i18n.default_locale = :de
    config.action_mailer.delivery_method = :letter_opener
    config.action_mailer.perform_deliveries = true
    config.autoload_paths += %W(#{config.root}/lib)
    require 'ext/integer'

    config.action_mailer.default_url_options = { host: 'peterpitch.de' }
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
