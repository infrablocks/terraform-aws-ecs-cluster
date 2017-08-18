require 'ruby_terraform'

require_relative '../../lib/configuration'

module TerraformModule
  class <<self
    def configuration
      @configuration ||= Configuration.new
    end

    def output_with_name(name)
      RubyTerraform.output(name: name, state: configuration.state_file)
    end

    def provision
      puts
      puts "Provisioning with deployment identifier: #{configuration.vars.deployment_identifier}"
      puts

      RubyTerraform.clean(
          directory: configuration.configuration_directory)
      RubyTerraform.init(
          source: configuration.source_directory,
          path: configuration.configuration_directory)
      Dir.chdir(configuration.configuration_directory) do
        RubyTerraform.apply(
            state: configuration.state_file,
            configuration_directory: configuration.configuration_directory,
            vars: configuration.vars.to_h)
      end

      puts
    end

    def destroy
      unless ENV['DEPLOYMENT_IDENTIFIER']
        puts
        puts "Destroying with deployment identifier: #{configuration.vars.deployment_identifier}"
        puts

        RubyTerraform.clean(
            directory: configuration.configuration_directory)
        RubyTerraform.init(
            source: configuration.source_directory,
            path: configuration.configuration_directory)
        Dir.chdir(configuration.configuration_directory) do
          RubyTerraform.destroy(
              configuration_directory: configuration.configuration_directory,
              state: configuration.state_file,
              force: true,
              vars: configuration.vars.to_h)
        end

        puts
      end
    end
  end
end