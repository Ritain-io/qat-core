When(/^I load the(?: "([^"]*)" environment from the)? "([^"]*)" folder$/) do |environment, directory|
  directory = dummy_project_path(directory)

  begin
    self.configuration = if environment
                           QAT::Configuration.new directory, environment
                         else
                           QAT::Configuration.new directory
												 end
		
  rescue => @error
  end
end

When /^I load the default folder$/ do
  self.configuration = QAT::Configuration.new
end

Then /^the loaded (directory|environment) is "([^"]*)"$/ do |accessor, value|
  value = dummy_project_path(value) if accessor == 'directory'

  assert_equal value, self.configuration.method(accessor).call
end

And /^I have the values in the "([^"]*)" configuration cache$/ do |cache, table|
  path     = cache.split('.')
  config   = configuration.dig(*path)
  expected = table.hashes.first
  expected.each do |key, value|
    key = key.split('.')
    assert config.key?(key.first), "Cache #{cache} has no key key #{key.first}"
    assert_equal value, config.dig(*key)
  end
end

Given /^I set the "([^"]*)" environment variable with value "([^"]*)"$/ do |key, value|
  override_env key, value
end

Given /^I unset the "([^"]*)" environment variable$/ do |key|
  override_env key, nil
end

And /^no environment is loaded$/ do
  assert_nil configuration.environment
end

And /^the cache is empty$/ do
  assert configuration.empty?, "Expected configuration cache to be empty. Keys found: #{configuration.keys}"
end

Given /^I change the current directory to "([^"]*)"$/ do |dir|
  self.original_dir = Dir.pwd
  Dir.chdir dummy_project_path(dir)
end

When /^I change the (directory|environment) to "([^"]*)"$/ do |accessor, value|
  value = nil if value == "nil"
  value    = dummy_project_path(value) if accessor == 'directory'
  accessor = :"#{accessor}="
  begin
    configuration.method(accessor).call value
  rescue => @error
  end
end

Then /^the environments list is$/ do |table|
  expected = table.transpose.headers
  found    = configuration.environments

  expected.each do |env|
    assert found.include? env
  end

  assert_equal expected.size, found.size

end

When /^I execute "([^"]*)" through all environments$/ do |params|
  @result_list = []
  configuration.each_environment do |env|
    @result_list << eval("env#{params}")
  end
end

Then /^the execution result list is$/ do |table|
  expected = table.transpose.headers

  expected.each_with_index do |value, index|
    assert_equal value, @result_list[index]
  end

  assert_equal expected.size, @result_list.size
end

When /^I execute "([^"]*)" in the current environment$/ do |params|
  @execution_result = eval("configuration#{params}")
end

Then /^the execution result is "([^"]*)"$/ do |result|
  assert_equal result, @execution_result
end

When(/^I try to edit the value at "([^"]*)" to "([^"]*)"$/) do |path, new_value|
  breadcrumbs = path.split('.').map { |breadcrumb| "['#{breadcrumb}']" }.join
  statement   = "configuration#{breadcrumbs} = '#{new_value}'"
  log.info "Evaluating: #{statement}"
  begin
    eval(statement)
  rescue => @error
  end
end

Then(/^the cached value at "([^"]*)" is still "([^"]*)"$/) do |path, value|
  breadcrumbs = path.split('.')
  assert_equal value, configuration.dig(*breadcrumbs)
end