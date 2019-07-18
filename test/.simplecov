# -*- encoding : utf-8 -*-
# Code coverage
require 'simplecov-json'
require 'simplecov-rcov'
require 'rubygems/specification'

gemspec  = Dir.glob(File.join(Dir.pwd, '..', '*.gemspec')).first
gem_spec = Gem::Specification.load(gemspec)
project  = gem_spec.name

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  SimpleCov::Formatter::RcovFormatter
]

ENV['SIMPLECOV_COVERAGE_DIR'] ||= ::File.join(SimpleCov.root, 'coverage')

eval_dir                  = ::File.realpath(::File.join(SimpleCov.root, '..', 'lib'))
ENV['SIMPLECOV_EVAL_DIR'] = eval_dir

SimpleCov.start do
  project_name project
  coverage_dir(ENV['SIMPLECOV_COVERAGE_DIR'])
  command_name(::File.basename(Dir.pwd))
  profiles.delete(:root_filter)
  filters.clear
  add_filter do |src|
    src.filename !~ /#{eval_dir}/
  end
  #add other filters bellow
  minimum_coverage 90
end