# frozen_string_literal: true

module CollectComment
  # Infrastructure to collect comments while yielding progress
  module CollectMonitor
    COLLECT_PROGRESS = {
      'STARTED' => 10,
      'STORING' => 90,
      'FINISHED' => 100
    }.freeze

    def self.starting_percent
      COLLECT_PROGRESS['STARTED'].to_s
    end

    def self.finished_percent
      COLLECT_PROGRESS['FINISHED'].to_s
    end

    def self.storing_percent
      COLLECT_PROGRESS['STORING'].to_s
    end
  end
end
