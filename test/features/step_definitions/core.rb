Given /^I have no object saved(?: in key "([^"]*)")?$/ do |key|
  key ||= default_key
  assert_nil core_target[key]
end

When /^I save an object(?: with key "([^"]*)")? using the "(\[\]=|store(?:_permanently)?)" method$/ do |key, method|
  key ||= default_key
  @saved_object = Object.new
  core_target.method(method.to_sym).call key, @saved_object
end

Then /^I have the (?:original|last) object saved(?: in key "([^"]*)")?$/ do |key|
  key ||= default_key
  assert_same @saved_object, core_target[key]
end

When /^I delete the object saved(?: with key "([^"]*)")?$/ do |key|
  key ||= default_key
  core_target.delete key
end

When /^I reset the Core instance$/ do
  core_target.reset!
end

When /^I make the key(?: "([^"]*)")? permanent$/ do |key|
  key ||= default_key
  core_target.make_permanent key
end

Given /^I am using the QAT proxy for the Core singleton$/ do
  self.core_target = QAT
end