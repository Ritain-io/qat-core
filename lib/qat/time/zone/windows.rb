require 'nokogiri'

module QAT
  class Time
    module Zone
      def get_local_tz
        local_zone = `tzutil /g`
        tzdata     = File.open(File.join(File.dirname(__FILE__), 'windows', 'tz_data.xml')) { |f| Nokogiri::XML(f) }
        tzdata.at_xpath("//mapZone[@other='#{local_zone}']")['type']
      end

      extend self
    end
  end
end