# frozen_string_literal: true

module YouFind
    module Service
      # Transaction to get captions filtered based on a given a http param
      class SearchCaptions
        include Dry::Transaction
  
        step :retrieve_captions
  
        private
  
        NOT_FOUND_ERR = 'No subtitles found'
        DB_ERR = 'Cannot access database'
  
        def retrieve_captions(input)
          video_id = Repository::For.klass(Entity::Video).find_id_from_origin_id(input[:video_id])
          text = input[:text].nil? ? "" : input[:text]
          captions = Repository::For.klass(Entity::Caption).find_captions(video_id, text)
          Success(Response::ApiResult.new(status: :ok, message: captions))
        end
      end
    end
  end
  