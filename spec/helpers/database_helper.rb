# frozen_string_literal: true

# Helper to clean database during test runs
module DatabaseHelper
  # TODO
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    YouFind::App.DB.run('PRAGMA foreign_keys = OFF')
    YouFind::Database::VideoOrm.map(&:destroy)
    YouFind::Database::CaptionOrm.map(&:destroy)
    YouFind::App.DB.run('PRAGMA foreign_keys = ON')
  end
end
