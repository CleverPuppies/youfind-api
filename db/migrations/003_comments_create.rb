# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments) do
      primary_key :id
      foreign_key :video_id

      String :yt_comment_id, null: false
      String :text, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
