require 'sequel'

Sequel.migration do
    change do
        create_table(:captions) do
            primary_key :id
            foreign_key :video_id

            String :start
            Integer :duration
            String :text

            DateTime :created_at
            DateTime :updated_at
        end
    end
end