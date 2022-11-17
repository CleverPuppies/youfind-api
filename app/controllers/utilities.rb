# frozen_string_literal: true

# Utility functions for Roda web app
class UtilityFunction
  def yt_url_checker(yt_video_url)
    (yt_video_url.include? 'youtube.com') &&
      (yt_video_url.include? 'v=') &&
      (yt_video_url.split('v=')[1].length == 11)
  end
end
