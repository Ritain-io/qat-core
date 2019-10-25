require 'socket'
require 'resolv'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/time'
require 'timecop'
require 'chronic'
require 'qat/logger'
require_relative 'core/version'

# load the correct module depending on OS
if /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
  require_relative 'time/zone/windows'
else
  require_relative 'time/zone/unix'
end

module QAT

  # This class represents QAT's Time extensions/enhancements.
  #
  # This class should be used globally to obtain {Time} object, allowing centralized modification of time generation.
  # There are three main featured united in this class:
  # * Clock Synchronization
  # * Time zone change
  # * Natural time expression parsing
  #@since 0.1.0
  class Time
    include Logger
    extend QAT::Time::Zone

    class << self

      # @!attribute default_sync_method
      #   @return [String] default method to be used in {synchronize}. Default: NTP
      attr_accessor :default_sync_method

      # Synchronizes the host's time/date with a remote server time/date
      #
      #@param host [String] host ip address/ hostname
      #@param method [String] method used for synchronization: +NTP+ or +SSH+.
      #@param opts [Hash] synchronization options
      #@return [ActiveSupport::TimeWithZone] Current time
      def synchronize(host, method=default_sync_method, opts={})
        opts ||= {} # opts can be a *nil* when it comes from qat/cucumber
        log.info { "Synchronizing with host #{host} using #{method} method" }
        sync_meth = to_method_name method
        unless respond_to? sync_meth
          log.error { "No synchronize method #{method} defined!" }
          raise NotImplementedError.new "No implementation of syncronization using the '#{method}' method"
        end

        host      = nil if host.to_s.empty?
        local_ips = Socket.ip_address_list.map &:ip_address

        dns_timeout = (opts and (opts[:dns_timeout] || opts[:timeout])) || 15

        Timeout.timeout dns_timeout do
          if local_ips.include? Resolv.getaddress(host)
            log.info { 'Target host is localhost, returning' }
            return now
          end
        end

        time_point = self.method(sync_meth).call(log, host, opts)
        raise ArgumentError.new "Expected the result from #{sync_meth} to be a Time object" unless time_point.is_a? ::Time
        log.info { "Synchronizing to #{time_point.strftime '%F %T,%L %z'}" }
        Timecop.travel time_point
        log.info { "Done!" }
        now
      end

      # Parses a string containing a natural language date or time.
      #
      #@param timestamp [String] text to parse
      #@return [Time] Result of the expression
      #@see http://www.rubydoc.info/gems/chronic/#Usage Chronic Gem
      def parse_expression timestamp
        Chronic.time_class = zone
        Chronic.parse timestamp
      end

      # Returns the current time zone. If none is set, the machine's time zone will be set.
      #
      #@return [ActiveSupport::TimeWithZone] Current time zone.
      def zone
        self.zone = get_local_tz or ActiveSupport::TimeZone['UTC'] unless ::Time.zone
        ::Time.zone
      end

      # Sets the timezone
      #
      #@param zone [String] time zone to use
      #@return [ActiveSupport::TimeWithZone]
      #@see zone
      def zone=(zone)
        ::Time.zone = zone
        log.warn "System TZ not detected, using UTC" if self.zone=='UTC'
      end

      # Returns the current time in the current time zone
      #
      #@return [ActiveSupport::TimeWithZone] Current time
      def now
        self.zone.now
      end

      # Defines synchronization instructions for a given method
      #
      #@param method [String] the method of synchronization (eg. HTTP, SSH, NTP)
      #@yield [logger, host, options] Block to execute the synchronization
      #@yieldparam [Log4r::Logger] logger Logging object with the Time channel
      #@yieldparam [String] host Logging object with the Time channel
      #@yieldparam [Hash] options Options passed through the {synchronize} method
      #@yieldreturn [ActiveSupport::TimeWithZone] Object with the value of the current time
      def sync_for_method(method, &block)
        raise ArgumentError.new 'No method name defined!' unless method
        raise ArgumentError.new "Block parameters should be 3: |logger, host, options|, but block only has #{block.arity} parameters" unless block.arity == 3
        define_singleton_method to_method_name(method), &block
      end

      private
      # Converts a string to a valid method name
      #
      #@param meth [String] wannabe method string
      #@return [Symbol]
      def to_method_name(meth)
        :"sync_#{meth.gsub(' ', '_').underscore}"
      end

    end

  end
end

QAT::Time.sync_for_method 'NTP' do |_, host, opts|
  require 'net/ntp'
  port    = opts[:port] || "ntp"
  timeout = opts[:dns_timeout] || 3
  Net::NTP.get(host, port, timeout).time
end

QAT::Time.sync_for_method 'SSH' do |_, host, options|
  require 'net/ssh'
  ssh_opts = options.dup
  user     = ssh_opts.delete :user
  command  = ssh_opts.delete(:command) || 'date +%FT%T,%3N%z'
  ssh_opts.select! { |opt| Net::SSH::VALID_OPTIONS.include? opt }
  ssh_opts[:non_interactive] = true if ssh_opts[:non_interactive].nil?
  result            = ''
  Net::SSH.start(host, user, ssh_opts) do |ssh|
    result = ssh.exec! command
  end

  ::Time.parse result
end

QAT::Time.default_sync_method = 'NTP'