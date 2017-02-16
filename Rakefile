require 'rspec/core/rake_task'
require 'securerandom'

require_relative 'lib/terraform'

DEPLOYMENT_IDENTIFIER = SecureRandom.hex[0, 8]

Terraform::Tasks.install('0.8.6')

task :default => 'test:integration'

namespace :test do
  RSpec::Core::RakeTask.new(:integration => ['terraform:ensure']) do
    ENV['AWS_REGION'] = 'eu-west-2'
  end
end

namespace :provision do
  desc 'Provisions module in AWS'
  task :aws, [:deployment_identifier] => ['terraform:ensure'] do |_, args|
    deployment_identifier = args.deployment_identifier || DEPLOYMENT_IDENTIFIER
    configuration_directory = Paths.from_project_root_directory('src')

    puts "Provisioning with deployment identifier: #{deployment_identifier}"

    Terraform.clean
    Terraform.apply(directory: configuration_directory, vars: {
        region: 'eu-west-2',
        vpc_cidr: "10.1.0.0/16",
        component: 'integration-tests',
        deployment_identifier: deployment_identifier
    })
  end
end

namespace :destroy do
  desc 'Destroys module in AWS'
  task :aws, [:deployment_identifier] => ['terraform:ensure'] do |_, args|
    deployment_identifier = args.deployment_identifier || DEPLOYMENT_IDENTIFIER
    configuration_directory = Paths.from_project_root_directory('src')

    puts "Destroying with deployment identifier: #{deployment_identifier}"

    Terraform.clean
    Terraform.destroy(directory: configuration_directory, vars: {
        region: 'eu-west-2',
        vpc_cidr: "10.1.0.0/16",
        component: 'integration-tests',
        deployment_identifier: deployment_identifier
    })
  end
end
