# frozen_string_literal: true

require 'roda'
require 'yaml'

module YouFind
  # Configuration for the App
  class App < Roda
    CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
    YT_TOKEN = CONFIG['API_KEY']
  end
end
