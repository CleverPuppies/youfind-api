# frozen_string_literal: true

require 'roda'
# require 'yaml'
require 'figaro'

module YouFind
  # Configuration for the App
  class App < Roda
    plugin :environments
    # CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
    # YT_TOKEN = CONFIG['API_KEY']
    Figaro.application = Figaro::Application.new(
      environment: environment,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load

    # Make the environment variables accessible
    def self.config() = Figaro.env
  end
end
