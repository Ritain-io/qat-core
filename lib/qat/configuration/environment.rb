module QAT
  class Configuration
    # Namespace for environment helper methods
    module Environment
      attr_reader :environment, :directory

      # Sets the configuration directory
      #
      # If an invalid path is given, an exception will thrown.
      # Given a valid +directory+ path:
      # - if the path is the same as the current path no configurations will loaded.
      # - if the identifier is for a new path, cache is cleared and the new configurations are loaded.
      #
      #@param directory [String] directory path
      #@raise [ArgumentError] When directory is invalid.
      def directory=(directory)
        raise ArgumentError.new 'No directory to set' unless directory
        unless File.exist? directory and File.directory? directory
          raise ArgumentError.new "#{directory} does not exist or is not a directory"
        end
        if @directory and File.absolute_path(directory) == File.absolute_path(@directory)
          log.info { "New directory is the same as the old one, cache will not be refreshed." }
        else
          old_dir    = @directory
          @directory = directory
          log.info { "Using directory #{@directory}" }
          reset_cache!
          load_env! if old_dir
        end
      rescue NoEnvironmentDefined
        log.warn "Environment is not defined! When defined, cache will be refreshed."
          #Loading can happen when environment is defined
      rescue NoEnvironmentFolder
        log.warn "Defined environment does not exist in current directory, choose a valid environment to load cache"
        self.environment = nil
      end

      # Sets the current environment
      #
      # Given a +environment+ identifier:
      # - if the identifier is the same as the current environment no configurations will loaded.
      # - if the identifier is for a new environment, cache is cleared and the new configurations are loaded.
      # - if a +nil+ environment is given, configuration cache is cleared.
      #
      #@param environment [String] environment identifier (name)
      #@raise [NoEnvironmentDefined] When no environment definition if found
      #@raise [NoEnvironmentFolder] When there is no environment folder for environment definition
      def environment=(environment)
        return if @environment == environment
        old_env      = @environment
        @environment = environment

        if environment
          load_env!
        else
          reset_cache!
        end
      rescue
        @environment = old_env
        raise
      end

      # Returns all the defined environments in the configuration directory
      #
      #@return [Array<String>] All environments defined
      def environments
        Dir.glob(File.join directory, '*/').map { |entry| File.basename(entry) }.reject { |entry| entry == 'common' }
      end

      # Executes a code +block+ in all environments of the current configuration directory
      #
      #@yield block to execute
      #@yieldparam [Configuration] Configuration loaded for each environment
      def each_environment(&block)
        old_env = @environment
        environments.sort.each do |env|
          self.environment = env
          block.call(self)
        end
      ensure
        self.environment = old_env
      end

      private
      # Validates and returns the environment to be used based on precedences
      # @param environment [String] environment reference
      # @return [String]
      def validate_environment(environment)
        if environment
          log.debug { "Reading environment from default variable" }
          environment
        elsif ENV['QAT_CONFIG_ENV']
          log.debug { "Reading environment from QAT_CONFIG_ENV environment variable" }
          ENV['QAT_CONFIG_ENV']
        else
          default_file = File.join @directory, 'default.yml'
          log.debug { "Reading default file #{default_file}" }
          read_yml(default_file)['env'] rescue nil
        end
      end
    end
  end
end