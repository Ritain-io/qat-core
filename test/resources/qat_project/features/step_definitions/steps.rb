Given /^true$/ do
  log "true"
  assert true
end

Given /^false$/ do
  log "false"
  assert false
end

Given /^pending$/ do
  log "pending"
  pending
end

When /^I access the value of "([^"]*)" in "([^"]*)" yml file$/ do |value, file|
  @value = QAT.configuration[file][value]
end

When /^I access the value of the environment name$/ do
  @value = QAT.configuration.environment
end

Then /^the value is "([^"]*)"$/ do |value|
  assert_equal value, @value
end