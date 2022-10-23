# frozen_string_literal: true

module YouFind
  # Model for Captions
  class Captions
    def initialize(captions)
      @captions = captions
    end

    def first
      @captions.first
    end
  end
end
