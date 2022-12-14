# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:videos) do
      primary_key :id

      String :origin_id, unique: true
      String :title
      String :views
      String :time, null: false
      String :url, null: false
      String :embedded_url, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
