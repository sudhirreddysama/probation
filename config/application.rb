require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ehpermits2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local
    
    config.action_controller.permit_all_parameters = true
    
    config.autoload_paths << "#{Rails.root}/app/lib"
# config.public_file_server.enabled = false

  end
end
