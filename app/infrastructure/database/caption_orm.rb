# frozen_string_literal: true

require 'sequel'

module YouFind
  module Database
    # Object Relational Mapper for Captions
    class CaptionOrm < Sequel::Model(:captions)
      many_to_one :video,
                  class: :'YouFind::Database::VideoOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
