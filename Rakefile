require 'rspec/core/rake_task'
require 'securerandom'
require 'git'
require 'semantic'
require 'rake_terraform'

require_relative 'lib/public_ip'

DEPLOYMENT_IDENTIFIER = SecureRandom.hex[0, 8]

RakeTerraform.define_installation_tasks(
    path: File.join(Dir.pwd, 'vendor', 'terraform'),
    version: '0.9.8')

def deployment_identifier_for(args)
  args.deployment_identifier ||
      ENV['DEPLOYMENT_IDENTIFIER'] ||
      DEPLOYMENT_IDENTIFIER
end

task :default => 'test:integration'

namespace :test do
  RSpec::Core::RakeTask.new(:integration => ['terraform:ensure']) do
    ENV['AWS_REGION'] = 'eu-west-2'
  end
end

RakeTerraform.define_command_tasks do |t|
  t.argument_names = [:deployment_identifier]

  t.configuration_name = 'ECS cluster module'
  t.source_directory = 'spec/infra'
  t.work_directory = 'build'

  t.state_file = File.join(Dir.pwd, 'terraform.tfstate')

  t.vars = lambda do |args|
    terraform_vars_for(
        deployment_identifier: deployment_identifier_for(args))
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

def terraform_vars_for(opts)
  {
      vpc_cidr: '10.1.0.0/16',
      region: 'eu-west-2',
      availability_zones: 'eu-west-2a,eu-west-2b',
      private_network_cidr: '10.0.0.0/8',

      component: 'test',
      deployment_identifier: opts[:deployment_identifier],

      bastion_ami: 'ami-bb373ddf',
      bastion_ssh_public_key_path:
          File.join(Dir.pwd, 'config/secrets/keys/bastion/ssh.public'),
      bastion_ssh_allow_cidrs: PublicIP.as_cidr,

      domain_name: 'greasedscone.uk',
      public_zone_id: 'Z4Q2X3ESOZT4N',
      private_zone_id: 'Z2CDAFD23Q10HO',

      cluster_name: 'test-cluster',
      cluster_instance_ssh_public_key_path:
          File.join(Dir.pwd, 'config/secrets/keys/cluster/ssh.public'),
      cluster_instance_type: 't2.medium',
      cluster_instance_ami: 'ami-3fb6bc5b',
      cluster_instance_root_block_device_size: 40,
      cluster_instance_docker_block_device_size: 60,

      cluster_minimum_size: 1,
      cluster_maximum_size: 3,
      cluster_desired_capacity: 2,

      infrastructure_events_bucket: 'tobyclemson-open-source',
  }
end
