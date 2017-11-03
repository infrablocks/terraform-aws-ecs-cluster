require 'rspec/core/rake_task'
require 'securerandom'
require 'git'
require 'semantic'
require 'rake_terraform'

require_relative 'lib/configuration'

configuration = Configuration.new

RakeTerraform.define_installation_tasks(
    path: File.join(Dir.pwd, 'vendor', 'terraform'),
    version: '0.9.8')

task :default => 'test:integration'

namespace :test do
  RSpec::Core::RakeTask.new(:integration => ['terraform:ensure']) do |t|
    ENV['AWS_REGION'] = 'eu-west-2'
  end
end

RakeTerraform.define_command_tasks do |t|
  t.argument_names = [:deployment_identifier]

  t.configuration_name = 'ECS cluster module'
  t.source_directory = configuration.source_directory
  t.work_directory = configuration.work_directory

  t.state_file = configuration.state_file

  t.vars = lambda do |args|
    configuration
        .vars_for(args)
        .to_h
  end
end

namespace :release do
  desc 'Increment and push tag'
  task :tag do
    repo = Git.open('.')
    tags = repo.tags
    latest_tag = tags.map { |tag| Semantic::Version.new(tag.name) }.max
    next_tag = latest_tag.increment!(:patch)
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'master', tags: true)
  end
end
