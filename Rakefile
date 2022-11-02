# frozen_string_literal: true

require 'rake/testtask'

task :default do
  puts `rake -T`
end

desc 'run the puma server'
task :run do
  sh 'bundle exec puma'
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment'
    require_relative 'spec/helpers/database_helper'

    def app() = YouFind::App
  end

  desc 'Run migrations'
  task :migrate => :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.DB, 'db/migrations')
  end

  desc 'Wipe records from all tables'
  task :wipe => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task :drop => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(YouFind::App.config.DB_FILENAME)
    puts "Deleted #{YouFind::App.config.DB_FILENAME}"
  end
end

desc 'Run application console'
task :console do
  sh 'pry -r ./load_all'
end

desc 'run tests'
task :spec do
  sh 'ruby spec/gateway_yt_spec.rb'
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  desc 'run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'complexity analysis'
  task :flog do
    sh 'flog app/'
  end

  desc 'code smell detector'
  task :reek do
    sh 'reek app/'
  end

  desc 'code style linter'
  task :rubocop do
    sh 'rubocop'
  end
end
