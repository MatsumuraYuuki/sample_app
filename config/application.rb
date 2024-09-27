require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SampleApp
  class Application < Rails::Application
    config.load_defaults 7.0
    # ImageMagickをMiniMagickのインターフェイスを経由して利用できるようにRailsを設定
    config.active_storage.variant_processor = :mini_magick
  end
end
