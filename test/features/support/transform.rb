Transform /^nil$/ do |_|
  nil
end

Transform /^\d+$/ do |num|
  num.to_i
end

Transform /^[A-Z:]+::VERSION$/ do |constant|
  eval constant
end