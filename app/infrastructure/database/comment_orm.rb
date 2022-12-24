# frozen_string_literal: true

require 'sequel'

module YouFind
  module Database
    # Object Relational Mapper for Video Entities
    class CommentOrm < Sequel::Model(:comments)
      many_to_one :video,
                  class: :'YouFind::Database::VideoOrm'
      
      plugin :timestamps, update_on_create: true
    end
  end
end
