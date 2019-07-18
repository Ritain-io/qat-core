module QAT
  class Configuration
    # Namespace for configuration parsing helper methods
    module Parser
      private

      # Loads all files from the root configuration folder
      #@param folder [String] root configuration folder path
      def load_root_files(folder)
        Dir.glob(File.join(folder, '*.yml')).each do |file|
          log.debug { "Loading file #{file}" }
          data = read_yml file

          base = File.basename(file, '.yml').to_sym

          @cache[base] ||= HashWithIndifferentAccess.new

          @cache[base].update data.with_indifferent_access do |key, old, new|
            log.debug { "Replacing key '#{key}' in cache with value '#{new}' (previously was '#{old}')" }
            new
          end
          log.debug { 'Loaded file' }
        end
      end

      # Loads all folders from the root configuration folder
      #@param folder [String] root configuration folder path
      def load_root_folders(folder)
        child_folders(folder).each do |child_folder|
          log.debug { "Loading folder #{child_folder}" }

          base = File.basename(child_folder).to_sym

          raise(InvalidFolderName, "A file with name #{base} exists and was already loaded!") if File.exist?("#{child_folder}.yml")

          @cache[base] ||= {}

          data = load_child_folder(child_folder).deep_symbolize_keys!

          merge_with_cache!(base, data)

          log.debug { 'Loaded folder' }
        end
      end

      # Return the child folder for a given directory
      # @param folder [String] directory path
      # @return [Array]
      def child_folders(folder)
        Dir.glob(File.join(folder, '*')).select { |entry| File.directory? entry }
      end

      def merge_with_cache!(base, data)
        symbolized_cache = @cache[base].deep_symbolize_keys

        symbolized_cache.deep_merge! data do |key, old, new|
          log.debug { "Replacing key '#{key}' in cache with value '#{new}' (previously was '#{old}')" }
          new
        end

        @cache[base] = symbolized_cache.with_indifferent_access
      end

      # Loads a configuration folder within another folder
      #@param folder [String] configuration folder path
      def load_child_folder(folder)
        content = {}

        Dir.glob(File.join(folder, '*.yml')).each do |file|
          base = File.basename(file, '.yml').to_sym

          content[base] = read_yml(file)
        end

        folders = Dir.glob(File.join(folder, '*')).select { |entry| File.directory? entry }
        folders.each do |folder_name|
          base = File.basename(folder_name).to_sym

          raise(InvalidFolderName, "A file with name #{base} exists and was already loaded!") if content[base]
          content[base] = load_child_folder(folder_name)
        end

        content
      end

      # Reads and parses a YAML file. Allows for ERB syntax to be used.
      #
      #@param file_path [String] YAML file path
      #@return [Hash]
      #@raise Psych::SyntaxError
      def read_yml(file_path)
        log.debug "Loading '#{file_path}'..."
        YAML::load(ERB.new(File.read(file_path)).result) || {}
      rescue Psych::SyntaxError
        log.error "Error parsing YAML file '#{file_path}'!"
        raise
      end
    end
  end
end