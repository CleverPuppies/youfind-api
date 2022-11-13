# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'
require 'yaml'

module YouFind
  # Configuration for the App
  class App < Roda
    plugin :environments

    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      configure :development, :test do
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
        ENV['YT_TOKEN'] = config.API_KEY
      end

      # Database Setup
      DB = Sequel.connect(ENV.fetch('DATABASE_URL', nil))
      def self.DB = DB # rubocop:disable Naming/MethodName
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock
  end
end
