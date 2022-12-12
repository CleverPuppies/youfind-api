# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'Caption Search Service Integration Test' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store video' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to do caption filter based on the input text' do
      YouFind::Service::AddVideo.new.call(video_id: VIDEO_ID)

      caption_search = YouFind::Service::SearchCaption.new.call(video_id: VIDEO_ID, text: 'google')

      _(caption_search.success?).must_equal true

      rebuilt = caption_search.value!.message

      _(rebuilt.captions[0].text).must_equal "and so, it is so famous\nthat you can just google it,"
    end
  end
end
