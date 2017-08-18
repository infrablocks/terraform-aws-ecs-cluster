require 'ruby_terraform'
require 'securerandom'
require 'open-uri'

require_relative 'vars'
require_relative '../../lib/paths'

module TerraformModule
  class <<self
    def state_file
      Paths.from_project_root_directory('terraform.tfstate')
    end

    def source_directory
      'spec/infra'
    end

    def configuration_directory
      'build/spec/infra'
    end

    def fixture
      @fixture ||= (ENV['FIXTURE'] ||
          Paths.from_project_root_directory('spec/fixtures/default.yml'))
    end

    def deployment_identifier
      @deployment_identifier ||= (ENV['DEPLOYMENT_IDENTIFIER'] ||
          SecureRandom.hex[0, 8])
    end

    def vars
      @vars ||= Vars.load_from(fixture, {
          project_directory: Paths.project_root_directory,
          public_ip: open('http://whatismyip.akamai.com').read,
          deployment_identifier: deployment_identifier
      })
    end

    def provision
      puts
      puts "Provisioning with deployment identifier: #{vars.deployment_identifier}"
      puts

      RubyTerraform.clean(
          directory: configuration_directory)
      RubyTerraform.init(
          source: source_directory,
          path: configuration_directory)
      Dir.chdir(configuration_directory) do
        RubyTerraform.apply(
            state: state_file,
            configuration_directory: configuration_directory,
            vars: vars.to_h)
      end

      puts
    end

    def destroy
      unless ENV['DEPLOYMENT_IDENTIFIER']
        puts
        puts "Destroying with deployment identifier: #{vars.deployment_identifier}"
        puts

        RubyTerraform.clean(
            directory: configuration_directory)
        RubyTerraform.init(
            source: source_directory,
            path: configuration_directory)
        Dir.chdir(configuration_directory) do
          RubyTerraform.destroy(
              configuration_directory: configuration_directory,
              state: state_file,
              force: true,
              vars: vars.to_h)
        end

        puts
      end
    end

    def output_with_name(name)
      RubyTerraform.output(name: name, state: state_file)
    end
  end
end