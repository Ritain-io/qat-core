module ConfigurationHelper

  attr_accessor :configuration, :original_dir

  def override_env key, value
    self.original_env[key] = ENV[key]

    ENV[key] = value
  end

  def reset_env!
    self.original_env.each do |key, value|
      ENV[key] = value
    end
  end

  def original_env
    @original_env ||= {}
  end

  def dummy_project_path path
    return nil unless path
    File.absolute_path(File.join(File.dirname(__FILE__), '..', 'resources', path))
  end

end
World ConfigurationHelper