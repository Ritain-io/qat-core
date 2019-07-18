require 'timezone_local'

module QAT
  class Time
    module Zone
      def get_local_tz
        TimeZone::Local.get
      end

      extend self
    end
  end
end