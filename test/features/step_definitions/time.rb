Given /^I freeze the clock(?: to "([^"]*)")?$/ do |time|
  Timecop.freeze time
  @initial_time  ||= ::Time.now
  @expected_time ||= @initial_time
end

When /^I synchronize the clock with host "([^"]*)"(?: using "([^"]*)")?$/ do |host, type|
  begin
    opts = {}
    if host == 'test host'
      case type
      when 'SSH'
        host = '172.18.0.2'

        opts = {
          user:     'user',
          password: 'password',
        }
      when 'NTP'
        host = 'pool.ntp.org'
      end
    end

    @time_result = if type
                     QAT::Time.synchronize host, type, opts
                   else
                     QAT::Time.synchronize host
                   end
  rescue NotImplementedError => @error
  end
end

Then /^the synchronization result is the current time$/ do
  assert_equal @expected_time, @time_result
end

Then /^the synchronization result has initial clock$/ do
  assert_equal @initial_time.to_i, @time_result.to_i
end

And /^the synchronization result has initial time zone$/ do
  expected_zone = if defined? TimeZone and defined? TimeZone::Local
                    @initial_time.zone
                  else
                    local_zone = `tzutil /g`
                    log.debug { "Current Windows timezone is '#{local_zone}'" }
                    tzdata    = File.open(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'qat', 'time', 'zone', 'windows', 'tz_data.xml')) { |f| Nokogiri::XML(f) }
                    iana_zone = tzdata.at_xpath("//mapZone[@other='#{local_zone}']")['type']
                    log.debug { "Found translation to IANA timezone '#{iana_zone}'" }
                    Time.use_zone iana_zone do
                      Time.zone.now.zone
                    end
                  end
  assert_equal expected_zone, @time_result.zone
end

When /^I set the current time zone to "([^"]*)"$/ do |zone|
  QAT::Time.zone = zone
end

And /^I get the current time$/ do
  @time_result = QAT::Time.now
end

Then /^the result clock value is correct$/ do
  assert_equal @expected_time.to_i, @time_result.to_i
end

And /^the result time zone is "([^"]*)"$/ do |zone|
  assert_includes [ActiveSupport::TimeZone::MAPPING[zone], zone], @time_result.time_zone.name
end

And /^the result time zone is the local zone$/ do
  expected_zone = if defined? TimeZone and defined? TimeZone::Local
                    TimeZone::Local.get
                  else
                    local_zone = `tzutil /g`
                    log.debug { "Current Windows timezone is '#{local_zone}'" }
                    tzdata    = File.open(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'qat', 'time', 'zone', 'windows', 'tz_data.xml')) { |f| Nokogiri::XML(f) }
                    iana_zone = tzdata.at_xpath("//mapZone[@other='#{local_zone}']")['type']
                    log.debug { "Found translation to IANA timezone '#{iana_zone}'" }
                    TZInfo::TimezoneProxy.new iana_zone.to_s
                  end
  assert_equal expected_zone, @time_result.time_zone.tzinfo
end

Given /^I create a dummy method for "([^"]*)" synchronization$/ do |meth|
  $executed = false

  QAT::Time.sync_for_method meth do |log, _, _|
    log.warn "EXECUTING #{meth}"
    $executed = true
    ::Time.now
  end

end

Given /^I create a synchronization method to (advance|go back) (\d+) (weeks?|days?|hours?|minutes?)$/ do |direction, quantity, units|

  units          = units.pluralize
  new_default    = [direction, quantity, units].join ' '
  quantity       *= -1 if direction == 'go back'
  @expected_time = ::Time.zone.now.advance(units.to_sym => quantity)

  QAT::Time.sync_for_method new_default do |_, _, _|
    ::Time.zone.now.advance(units.to_sym => quantity)
  end

  @previous_default             = QAT::Time.default_sync_method
  QAT::Time.default_sync_method = new_default

end

Then /the result clock is expected to (advance|go back) (\d+) (weeks?|days?|hours?|minutes?)/ do |direction, quantity, units|

  units    = units.pluralize
  quantity *= -1 if direction == 'go back'

  @expected_time = ::Time.zone.now.advance(units.to_sym => quantity)

  assert_equal @expected_time, @time_result

end

Given /^I create a synchronization method with "(\d+)" parameters$/ do |num|

  params = ''
  params = "|#{Array.new(num, '_').join(',')}|" if num > 0

  code = eval "proc {#{params} ::Time.now}"

  begin
    QAT::Time.sync_for_method 'should fail', &code
  rescue ArgumentError => @error
  end

end

And(/^the dummy method was( not)? executed$/) do |negative|
  if negative
    refute $executed
  else
    assert $executed
  end
end

When(/^I parse the time string "([^"]*)"$/) do |string|
  @time_result = QAT::Time.parse_expression string
end