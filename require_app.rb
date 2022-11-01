# frozen_string_literal: true

def require_app
  Dir.glob('./app/**/*.rb').each do |file|
    require file
  end
  Dir.glob('./config/**/*.rb').each do |file|
    require file
  end
end
