# frozen_string_literal: true

require 'rake/testtask'

task :default do
  puts `rake -T`
end

desc 'run the puma server'
task :run do
  sh 'bundle exec puma'
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
    sh 'flog lib/'
  end

  desc 'code smell detector'
  task :reek do
    sh 'reek lib/'
  end

  desc 'code style linter'
  task :rubocop do
    sh 'rubocop'
  end
end
