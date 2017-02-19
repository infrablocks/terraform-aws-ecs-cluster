require 'rake'
require 'rake/tasklib'
require 'rake_dependencies'
require 'net/http'
require 'zip'
require 'fileutils'
require 'lino'

require_relative 'paths'

module Terraform
  DEPENDENCY_NAME = 'terraform'
  DEFAULT_PATH = Paths.from_project_root_directory('vendor', 'terraform')
  DEFAULT_BINARY = File.join(DEFAULT_PATH, "bin", "terraform")
  DEFAULT_VERSION = '0.8.6'

  class <<self
    def clean(opts = {})
      directory = opts[:directory] ||
          Paths.from_project_root_directory(".terraform")
      FileUtils.rm_rf(directory)
    end

    def apply(opts)
      Commands::Apply.new.execute(opts)
    end

    def destroy(opts)
      Commands::Destroy.new.execute(opts)
    end

    def output(opts)
      Commands::Output.new.execute(opts)
    end

    def remote_config(opts)
      Commands::RemoteConfig.new.execute(opts)
    end

    def output_from_remote(opts)
      output_name = opts[:name]
      remote_opts = opts[:remote]

      clean
      remote_config(remote_opts)
      output(name: output_name)
    end
  end

  module Commands
    class Apply
      attr_reader :binary

      def initialize(binary = DEFAULT_BINARY)
        @binary = binary
      end

      def execute(opts)
        directory = opts[:directory]
        state = opts[:state]
        vars = opts[:vars]

        Lino::CommandLineBuilder.for_command(binary)
            .with_subcommand('apply') do |sub|
          vars.each do |key, value|
            sub = sub.with_option('-var', "'#{key}=#{value}'")
          end
          sub = sub.with_option('-state', state) if state
          sub
        end
            .with_argument(directory)
            .build
            .execute
      end
    end

    class Destroy
      attr_reader :binary

      def initialize(binary = DEFAULT_BINARY)
        @binary = binary
      end

      def execute(opts)
        directory = opts[:directory]
        state = opts[:state]
        vars = opts[:vars]

        Lino::CommandLineBuilder.for_command(binary)
            .with_subcommand('destroy') do |sub|
          vars.each do |key, value|
            sub = sub.with_option('-var', "'#{key}=#{value}'")
          end
          sub = sub.with_option('-state', state) if state
          sub
        end
            .with_argument(directory)
            .build
            .execute(stdin: 'yes')
      end
    end

    class Output
      attr_reader :binary

      def initialize(binary = DEFAULT_BINARY)
        @binary = binary
      end

      def execute(opts)
        state = opts[:state]
        name = opts[:name]
        stdout = StringIO.new

        builder = Lino::CommandLineBuilder.for_command(binary)
                      .with_option_separator('=')
                      .with_subcommand('output') do |sub|
          sub = sub.with_option('-state', state) if state
          sub
        end
        builder = builder.with_argument(name) if name
        builder
            .build
            .execute(stdout: stdout)

        result = stdout.string
        name ?
            result.chomp :
            result
      end
    end

    class RemoteConfig
      attr_reader :binary

      def initialize(binary = DEFAULT_BINARY)
        @binary = binary
      end

      def execute(opts)
        backend = opts[:backend]
        config = opts[:config]

        Lino::CommandLineBuilder.for_command(binary)
            .with_subcommand('remote')
            .with_subcommand('config') do |sub|
          sub = sub.with_option('-backend', backend)
          config.each do |key, value|
            sub = sub.with_option('-backend-config', "'#{key}=#{value}'")
          end
          sub
        end
            .build
            .execute
      end
    end
  end

  module Tasks
    def self.install(version = '0.6.16')
      RakeDependencies::Tasks::All.new do |t|
        t.namespace = :terraform
        t.dependency = 'terraform'
        t.version = version
        t.path = Paths.from_project_root_directory('vendor', 'terraform')
        t.type = :zip

        t.os_ids = {mac: 'darwin', linux: 'linux'}

        t.uri_template = "https://releases.hashicorp.com/terraform/<%= @version %>/terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>"
        t.file_name_template = "terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>"

        t.needs_fetch = lambda do |parameters|
          terraform_binary = File.join(parameters[:path], parameters[:binary_directory], 'terraform')
          version_string = StringIO.new

          if File.exist?(terraform_binary)
            Lino::CommandLineBuilder.for_command(terraform_binary)
                .with_flag('-version')
                .build
                .execute(stdout: version_string)

            if version_string.string.lines.first =~ /#{version}/
              return false
            end
          end

          return true
        end
      end
    end
  end
end
