#encoding: utf-8

Gem::Specification.new do |gem|
  gem.name        = 'qat-core'
  gem.version     = '7.0.0'
  gem.summary     = %q{QAT-Core is QAT's toolkit engine for automating tests.}
  gem.description = <<-DESC
  QAT-Core is QAT's engine, including a collection of modules for:
    - Configuration management and persistence
    - Time manipulation
  DESC
  gem.email    = 'qatoolkit@readinessit.com'

  gem.homepage = 'https://www.readinessit.com'

  gem.metadata    = {
      'source_code_uri'   => 'https://github.com/readiness-it/qat-core'
  }
  gem.authors = ['QAT']
  gem.license = 'GPL-3.0'

  extra_files = %w[LICENSE]
  gem.files   = Dir.glob('{lib}/**/*') + extra_files

  gem.required_ruby_version = '~> 2.3'

  gem.add_dependency 'qat-logger', '~> 6.0'

  gem.add_dependency 'activesupport'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'tzinfo-data'

  gem.add_dependency 'net-ssh', '~> 3.1'
  gem.add_dependency 'net-ntp', '~> 2.1', '>= 2.1.3'
  gem.add_dependency 'chronic', '~> 0.10', '>= 0.10.2'
  gem.add_dependency 'timecop', '~> 0.8'
  gem.add_dependency 'timezone_local', '~> 0.1', '>= 0.1.5'
  gem.add_dependency 'little-plugger', '~> 1.1', '>= 1.1.4'

  gem.add_development_dependency 'qat-devel', '~> 7.0.0'

  gem.add_development_dependency 'minitest', '~> 5.7'
  gem.add_development_dependency 'aruba', '~> 0.9'
  gem.add_development_dependency 'retriable', '~> 3.0'
  gem.add_development_dependency 'httparty', '~> 0.15'
end
