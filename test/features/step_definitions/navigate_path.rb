Given(/^a complex structure:$/) do |text|
  @structure = eval(text)
end

When(/^the value from path "([^"]*)" is obtained$/) do |path|
  path_elements = path.split('.')
  @values       = QAT::Utils::Hash.navigate_path(@structure, path_elements)
end

Then(/^the obtained value is "([^"]*)"$/) do |value|
  assert_equal(value.to_s, @values.first.to_s)
end

Then(/^the obtained values are:$/) do |table|
  values        = table.hashes.map(&:values).flatten
  actual_values = @values.first
  valid_values  = values.all? { |value| actual_values.include?(value) }
  same_size     = values.size == actual_values.size
  assert(valid_values && same_size)
end