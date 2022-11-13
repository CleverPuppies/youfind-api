# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:captions) do
      primary_key :id
      foreign_key :video_id

      Float :start, null: false
      Float :duration, null: false
      String :text

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
