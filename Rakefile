#!/usr/bin/env rake
#encoding: utf-8

require 'qat/devel/tasks'

require 'erb'

namespace :qat do
  namespace :core do
    def clear_reports_folder!
      mkdir_p 'public'
      rm_rf ::File.join('public', '*')
    end

    desc 'Run all test scenarios containing given tags'
    task :tags, :tags do |_, params|
      tags = params[:tags].is_a?(String) ? [params[:tags]] : params[:tags].to_a
      raise ArgumentError.new "A tag is needed to execute the task!" unless tags.any?
      ENV['CUCUMBER_OPTS'] = "#{ENV['CUCUMBER_OPTS']} --tags #{tags.join(',')}"

      cd 'test' do
        Cucumber::Rake::Task.new('run', 'Run all test scenarios containing given tags') do |task|
          clear_public_folder!
        end.runner.run
      end
    end

    namespace :gemfile do
      desc 'Generate example gemfile for gem usage'
      task :example do
        @gem_name = 'qat-core'

        spec = Gem::Specification::load("#{@gem_name}.gemspec")

        @gem_version = spec.version
        @development_dependencies = spec.development_dependencies

        File.write 'Gemfile.example', ERB.new(<<ERB).result
source 'https://rubygems.org'

gem '<%= @gem_name %>', '<%= @gem_version %>'
<% @development_dependencies.each do |dependency| %>gem '<%= dependency.name %>', '<%= dependency.requirements_list.reverse.join "', '"%>'
<% end %>
ERB
      end

      desc 'Generate default gemfile'
      task :default do
        File.write 'Gemfile.default', <<GEMFILE
source 'https://rubygems.org'

gemspec
GEMFILE
      end
    end

    namespace :nexus do

      desc 'Generate nexus configuration for deploy'
      task :config do
        File.write 'nexus', ERB.new(<<ERB).result
---
:url: <%= ENV['NEXUS_DEPLOY_URL'] %>
:authorization: Basic <%= ["#{ENV['NEXUS_DEPLOY_USER']}:#{ENV['NEXUS_DEPLOY_PASS']}"].pack('m').delete("\r\n") %>
ERB
      end
    end
  end
end