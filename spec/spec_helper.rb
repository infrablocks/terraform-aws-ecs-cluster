require 'bundler/setup'

require 'awspec'
require 'open-uri'

require 'support/shared_contexts/terraform'

require_relative '../lib/terraform'

RSpec.configure do |config|
  deployment_identifier = ENV['DEPLOYMENT_IDENTIFIER']

  def current_public_ip_cidr
    "#{open('http://whatismyip.akamai.com').read}/32"
  end

  config.example_status_persistence_file_path = '.rspec_status'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.add_setting :vpc_cidr, default: "10.1.0.0/16"
  config.add_setting :region, default: 'eu-west-2'
  config.add_setting :availability_zones, default: 'eu-west-2a,eu-west-2b'

  config.add_setting :component, default: 'integration-tests'
  config.add_setting :deployment_identifier,
      default: deployment_identifier || SecureRandom.hex[0, 8]

  config.add_setting :bastion_ami, default: 'ami-bb373ddf'
  config.add_setting :bastion_ssh_public_key_path, default: 'config/secrets/keys/bastion/ssh.public'
  config.add_setting :bastion_ssh_allow_cidrs, default: "#{current_public_ip_cidr}"

  config.add_setting :domain_name, default: 'greasedscone.uk'
  config.add_setting :public_zone_id, default: 'Z2WA5EVJBZSQ3V'

  config.before(:suite) do
    variables = RSpec.configuration
    configuration_directory = Paths.from_project_root_directory('spec/infra')

    puts
    puts "Provisioning with deployment identifier: #{variables.deployment_identifier}"
    puts

    Terraform.clean
    Terraform.get(directory: configuration_directory)
    Terraform.apply(directory: configuration_directory, vars: {
        vpc_cidr: variables.vpc_cidr,
        region: variables.region,
        availability_zones: variables.availability_zones,

        component: variables.component,
        deployment_identifier: variables.deployment_identifier,

        bastion_ami: variables.bastion_ami,
        bastion_ssh_public_key_path: variables.bastion_ssh_public_key_path,
        bastion_ssh_allow_cidrs: variables.bastion_ssh_allow_cidrs,

        domain_name: variables.domain_name,
        public_zone_id: variables.public_zone_id
    })
  end

  config.after(:suite) do
    unless deployment_identifier
      variables = RSpec.configuration
      configuration_directory = Paths.from_project_root_directory('spec/infra')


      puts
      puts "Destroying with deployment identifier: #{variables.deployment_identifier}"
      puts

      Terraform.clean
      Terraform.get(directory: configuration_directory)
      Terraform.destroy(directory: configuration_directory, vars: {
          vpc_cidr: variables.vpc_cidr,
          region: variables.region,
          availability_zones: variables.availability_zones,

          component: variables.component,
          deployment_identifier: variables.deployment_identifier,

          bastion_ami: variables.bastion_ami,
          bastion_ssh_public_key_path: variables.bastion_ssh_public_key_path,
          bastion_ssh_allow_cidrs: variables.bastion_ssh_allow_cidrs,

          domain_name: variables.domain_name,
          public_zone_id: variables.public_zone_id
      })

      puts
    end
  end
end
