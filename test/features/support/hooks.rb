require 'fileutils'

# After do
#   QAT::Config.clear
# end

After '@temp_folder' do
  FileUtils.remove_entry_secure(File.join(File::SEPARATOR, 'tmp', 'name1'))
end

After '@core' do
  QAT::Core.instance.instance_exec do
    @storage    = {}
    @exceptions = []
  end
end

After 'not @stdout_redirect' do |scenario|
  if scenario.status == :passed
    log.info { "Scenario #{scenario.name} #{scenario.status}!\n\n" }
  else
    log.error { "Scenario #{scenario.name} #{scenario.status}!\n\n" }
  end
end

After '@config' do
  begin
    reset_env!
    Dir.chdir original_dir if original_dir
  rescue => e
    log.error e
  end
end

After '@time' do
  Timecop.return
  QAT::Time.default_sync_method = @previous_default if @previous_default
end

Before do
  @test_start_ts = Time.now.iso8601(3)
end

After do
  @error                 = nil
  @for_validations_error = nil
end
