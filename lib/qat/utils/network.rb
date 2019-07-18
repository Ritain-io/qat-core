module QAT

  # This is a wrapper namespace for utility methods in QAT
  module Utils
    # This module gives helper methods for IP handling and/or validation
    module Network
      # Validates if +ip+ is a valid IP Address.
      #
      #@param ip [String] wannabe IP Address
      #@return [Boolean]
      def is_ip?(ip)
        !!IPAddr.new(ip) rescue false
      end

      extend self
    end
  end
end