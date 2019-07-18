Then /^a "([^"]*)" exception is raised$/ do |klass|
  refute_nil @error
  assert_equal klass, @error.class.to_s
  @for_validations_error = @error
  @error            = nil
end

Then /^no exception is raised$/ do
  refute @error
end

And(/^the exception reads "([^"]*)"$/) do |text|
  assert_equal text, @for_validations_error.message.strip
end