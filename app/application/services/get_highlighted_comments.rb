# frozen_string_literal: true

module YouFind
  module Service
    # Transaction to get video from db and filter its captions given a text param
    class GetHighlightedComments
      include Dry::Transaction

      step :find_video_details
      step :request_comment_collection_worker
      step :extract_timetags
      step :generate_highlights

      private

      NO_VIDEO_ERR = 'Video not found'
      NOT_FOUND_ERR = 'Comments not found'
      YT_NOT_FOUND_ERR = 'No comments found on YouTube'
      NO_TIMETAGS_ERR = 'No time tags found in the comments'
      DB_ERR = 'Cannot access database'
      QUEUE_ERR = 'Cannot access the queue service (SQS)'
      PROCESSING_MSG = 'Processing the Youtube comment collecting request'

      def find_video_details(input)
        input[:video] = Repository::For.klass(Entity::Video).find_origin_id(
          input[:video_id]
        )
        if input[:video]
          Success(input)
        else
          Failure(Response::ApiResult.new(status: :not_found, message: NO_VIDEO_ERR))
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      def request_comment_collection_worker(input)
        video_pk = Repository::For.klass(Entity::Video).find_id_from_origin_id(input[:video_id])
        input[:video_pk] = video_pk
        comments = comments_in_database(input)

        if comments.empty?
          begin
            Messaging::Queue
              .new(App.config.COMMENT_COLLECTOR_QUEUE_URL, App.config)
              .send(collect_request_json(input))

            Failure(
              Response::ApiResult.new(
                status: :processing,
                message: { request_id: input[:request_id], message: PROCESSING_MSG }
              )
            )
          rescue StandardError => e
            puts e
            Failure(Response::ApiResult.new(status: :internal_error, message: QUEUE_ERR))
          end
        else
          input[:comments] = comments
          Success(input)
        end
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
        captions = YouFind::Repository::For.klass(Entity::Caption).find_captions(input[:video_pk])
        captions_timestamps = captions.map { |caption| caption[:start] }

        time_tags_counter = Hash.new(0)
        input[:time_tags].each do |time_tag|
          time_tag = time_tag_to_timestamp(time_tag)

          inf_timestamps = captions_timestamps.select { |caption_timestamp| caption_timestamp < time_tag }
          normalized_time_tag = inf_timestamps.min_by do |inf_timestamp|
            (time_tag - inf_timestamp).abs
          end.to_i
          time_tags_counter[normalized_time_tag] += 1
        end
        highlights_time_tags = time_tags_counter.sort_by { |_key, value| value }.first(10).to_h
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

      def comments_in_database(input)
        YouFind::Repository::Comments.find_comments(input[:video_pk])
      end

      def time_tag_to_timestamp(time_tag)
        return time_tag.sub(':', '.').to_f if time_tag.count('.') == 1

        time_tag.sub(':', '').sub(':', '.').to_f
      end

      def collect_request_json(input)
        Response::CollectRequest.new(input[:video_id], input[:request_id])
                                .then { Representer::CollectRequest.new(_1) }
                                .then(&:to_json)
      end
    end
  end
end
