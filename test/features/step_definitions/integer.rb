When(/^I generate a random integer$/) do
  @integer = Integer.random
  log.info "Generated integer '#{@integer}'!"
end

When(/^I generate a random integer with length (.*)$/) do |length|
  @integer = Integer.random(length)
  log.info "Generated integer '#{@integer}'!"
end

Then(/^the generated integer has length (.*)$/) do |length|
  assert(@integer.is_a?(Integer))
  assert_equal(length.to_i, @integer.to_s.size)
end

When(/^I generate a random integer with argument "([^"]*)"$/) do |arg|
  begin
    @integer = Integer.random(eval(arg))
  rescue => @error
  end
end