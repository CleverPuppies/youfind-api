# frozen_string_literal: true

module YouFind
    module Service
      # Transaction to get video from db and filter its captions given a text param
      class GetHighlightedComments
        include Dry::Transaction
        
        step :retrieve_comments
        step :extract_timetags
        step :generate_highlights
  
        private
  
        NOT_FOUND_ERR = 'Comments not found'
        YT_NOT_FOUND_ERR = 'No comments found on YouTube'
        NO_TIMETAGS_ERR = 'No time tags found in the comments'
        DB_ERR = 'Cannot access database'

        def retrieve_comments(input)
          comments = comments_in_database(input)
          if comments.empty?
            input[:comments] = comments_from_youtube(input)
            store_comments(input)
          else
            input[:comments] = comments
          end
    
          Success(input)
        rescue StandardError => e
          puts e.backtrace.join("\n")
          Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
        end

        def extract_timetags(input)
          time_tag_regex = /[0-9]+:[0-9]+(?::[0-9]+|)/
          time_tags = input[:comments].map do |comment|
            comment.to_attr_hash[:text].scan(time_tag_regex)
          end.flatten.compact
          
          input[:time_tags] = time_tags
          raise NO_TIMETAGS_ERR if time_tags.nil?

          Success(input)
        end

        def generate_highlights(input)
          video_id = Repository::For.klass(Entity::Video).find_id_from_origin_id(input[:video_id])
          captions = YouFind::Repository::For.klass(Entity::Caption).find_captions(video_id)
          captions_timestamps = captions.map { |caption| caption[:start] }
          
          time_tags_counter = Hash.new(0)
          input[:time_tags].each do |time_tag|
            time_tag = time_tag_to_timestamp(time_tag)

            inf_timestamps = captions_timestamps.select { |caption_timestamp| caption_timestamp < time_tag }
            normalized_time_tag = inf_timestamps.min_by do |inf_timestamp|
              (time_tag-inf_timestamp).abs
            end

            time_tags_counter[normalized_time_tag] += 1
          end

          highlights_time_tags = time_tags_counter.sort_by { |key, value| value }.first(10).to_h
          Success(Response::ApiResult.new(status: :ok, message: highlights_time_tags.keys.to_s))
        rescue StandardError => e
          puts e.backtrace.join("\n")
          Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
        end

        # following are support methods that other services could use

        def comments_from_youtube(input)
          Youtube::CommentMapper
            .new(App.config.YOUTUBE_API_KEY)
            .load_comments(input[:video_id])
        rescue StandardError
          raise YT_NOT_FOUND_ERR
        end

        def store_comments(input)
          input[:comments].each do |comment|
            YouFind::Repository::Comments.create(comment)
          end
        rescue StandardError => e
          puts e.backtrace.join("\n")
          Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
        end

        def comments_in_database(input)
          YouFind::Repository::Comments.find_comments(input[:video_id])
        end

        def time_tag_to_timestamp(time_tag)
          return time_tag.sub(':','.').to_f if time_tag.count('.') == 1
          
          time_tag.sub(':','').sub(':','.').to_f
        end
      end
    end
  end
  