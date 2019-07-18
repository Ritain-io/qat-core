Given(/^an? (?:array|hash) defined as "([^"]*)"$/) do |object|
  @reference_object = eval(object)
  @object           = eval(object)
end

When(/^the method "([^"]*)" is call on the existing (?:array|hash)$/) do |method|
  @new_object = @object.method(method.to_sym).call
end

Then(/^the (new )?(?:array|hash) is "([^"]*)"$/) do |toggle, object|
  comparable = if toggle
                 @new_object
               else
                 @object
               end
  expected   = eval(object)
  assert_equal(expected, comparable)
end

And(/^the existing (?:array|hash) remains unchanged$/) do
  assert_equal(@reference_object, @object)
end