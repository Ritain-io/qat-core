# -*- encoding : utf-8 -*-
require 'forwardable'
require 'yaml'
require 'erb'
require 'ipaddr'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/deep_merge'
require_relative 'core'
require_relative 'utils/network'
require_relative 'configuration/environment'
require_relative 'configuration/parser'
require 'qat/logger'

#QAT Module works as a namespace for all sub modules.
#Some singleton methods are also available, as defined by various sub classes.
module QAT

  # This class represents {QAT}'s Configuration manager
  #
  # This class should be used to manage configurations from multiple environments in test projects.
  # Given a defined environment, all configurations for that environment will be loaded into a cache
  # from the corresponding folder (with the same name) under the +config+ directory.
  #
  # A +common+ folder is also supported which contains configurations shared between multiple environments.
  # A configuration file can exist in both the environment folder and the common folder with the content of both
  # being merged at load time and the configuration from the environment taking precedence over the shared (common)
  # configuration.
  #
  # Also supported is the cross-referencing of configurations between files.
  # Given a file 'foo.yml' with a configuration 'foo: bar'
  # and a second file 'baz.yml' with configuration 'baz: foo.foo',
  # after configurations are loaded to cache, the value of 'baz' in cache will be 'bar'.
  # Cross-referencing between files is made with syntax:
  # - +<file.yml>+
  #     `
  #     key: <other_file.yml>.<key>
  #     `
  #@since 0.1.0
  class Configuration
    extend Forwardable
    include QAT::Logger
    include Utils::Network
    include Environment
    include Parser

    def_delegators :@cache, :empty?, :fetch, :keys, :has_key?, :include?, :key?, :member?, :reject, :select, :values_at,
                   :stringify_keys, :symbolize_keys, :dig

    #@param directory [String] path to configuration directory
    #@param environment [String] name of the environment from which configurations will be loaded
    def initialize(directory=Dir.pwd, environment=nil)
      self.directory = directory
      log.info { "Initializing configuration from directory #{self.directory}" }
      self.environment = validate_environment(environment)
      log.info { "Initialized configuration with environment '#{self.environment}'" }
    end

    # Returns a copy from cache to avoid data manipulation on runtime
    #@param key [String|Symbol] cache key
    #@return [Object]
    def [](key)
      @cache[key].deep_dup
    end

    private
    # Resolves references between configuration files.
    def resolve_references!
      intersect_config @cache
    end

    # Resets the configuration cache
    def reset_cache!
      @cache = ActiveSupport::HashWithIndifferentAccess.new unless @cache and @cache.empty?
    end

    # Loads the environment configurations for the defined environment.
    # If an invalid +environment+ was given, an exception is thrown.
    #
    #@see #environment=
    #@raise [NoEnvironmentDefined] When no environment definition if found
    #@raise [NoEnvironmentFolder] When there is no environment folder for environment definition
    def load_env!
      raise NoEnvironmentDefined.new 'No environment definition found!' unless environment

      env_folder = File.join @directory, environment
      raise NoEnvironmentFolder.new "No folder '#{environment}' found in directory #{@directory}" unless Dir.exist? env_folder

      common_folder = File.join @directory, 'common'

      reset_cache!
      log.debug { "Loading configuration cache using environment #{environment}" }

      [common_folder, env_folder].each do |folder|
        if Dir.exist? folder
          log.debug { "Loading folder #{folder}" }
          load_root_files(folder)
          load_root_folders(folder)
        else
          log.debug { "Folder #{folder} not found, skipping" }
        end
      end
      log.info { "Configuration cache loaded" }

      resolve_references!

      log.info { "Configuration cache references resolved" }
    end

    # Analyses +config+ and replaces references between configuration files.
    #
    #@param config [ActiveSupport::HashWithIndifferentAccess]
    #@return [ActiveSupport::HashWithIndifferentAccess]
    def intersect_config(config)
      new_hash = {}
      config.each do |key, value|
        if value.is_a?(Hash)
          new_value = intersect_config(value)
        elsif value.is_a?(Array)
          new_value = value.map { |element| referenced_value(element) }
        else
          new_value = referenced_value(value)
        end
        new_hash[key] = new_value
      end
      config.update(new_hash)
    end

    # Returns the value referenced by a given +reference+.
    #
    #@param reference [Object] object containing references/values
    #@return [Object]
    def referenced_value(reference)
      if reference.is_a?(Array)
        reference.each { |element| referenced_value(element) }
      elsif reference.is_a?(Hash)
        reference.each { |key, value| reference[key] = referenced_value(value) }
      else
        return reference unless reference.is_a?(String) && reference.match(/^\w+(\.\w+)+$/) && !is_ip?(reference)

        value = reference.split('.').inject(@cache) { |cache, key| cache[key] } rescue reference

        if value.equal? reference
          log.debug { "Reference '#{reference}' not found, keeping original value" }
        else
          log.debug { "Replacing '#{reference}' reference for value '#{value}'" }
        end

        value
      end
    end

    public
    # This class represents a configuration loading error when there is no defined environment
    class NoEnvironmentDefined < StandardError
    end
    # This class represents a configuration loading error when there is no folder for defined environment
    class NoEnvironmentFolder < StandardError
    end
    # This class represents a configuration loading error when there is a folder has an invalid name
    class InvalidFolderName < StandardError
    end
  end

  # Singleton access to a {QAT::Configuration} object. Only available in cucumber mode.
  #@return [QAT::Configuration] Configuration object for the config folder.
  def self.configuration
    to_load        = ENV['QAT_CONFIG_FOLDER'] || 'config'
    @configuration ||= QAT::Configuration.new to_load
  end
end
