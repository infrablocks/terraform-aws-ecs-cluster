require 'securerandom'
require 'open-uri'
require 'ostruct'

require_relative 'paths'
require_relative 'vars'
require_relative 'public_address'

class Configuration
  def state_file
    Paths.from_project_root_directory('terraform.tfstate')
  end

  def source_directory
    'spec/infra'
  end

  def work_directory
    'build'
  end

  def configuration_directory
    File.join(work_directory, source_directory)
  end

  def vars_template_file
    ENV['VARS_TEMPLATE_FILE'] ||
        Paths.from_project_root_directory('config/vars/default.yml.erb')
  end

  def deployment_identifier
    deployment_identifier_for(OpenStruct.new)
  end

  def deployment_identifier_for(args)
    args.deployment_identifier ||
        ENV['DEPLOYMENT_IDENTIFIER'] ||
        SecureRandom.hex[0, 8]
  end

  def vars
    vars_for(OpenStruct.new)
  end

  def vars_for(args)
    @vars ||= Vars.load_from(vars_template_file, {
        project_directory: Paths.project_root_directory,
        public_ip: PublicAddress.as_ip_address,
        deployment_identifier: deployment_identifier_for(args)
    })
  end
end