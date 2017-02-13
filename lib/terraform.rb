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
    class <<self
      include ::Rake::DSL if defined?(::Rake::DSL)

      def install(version=DEFAULT_VERSION)
        namespace :terraform do
          RakeDependencies::Tasks::Clean.new do |t|
            t.path = DEFAULT_PATH
            t.dependency = DEPENDENCY_NAME
          end
          RakeDependencies::Tasks::Download.new do |t|
            t.type = :zip
            t.path = DEFAULT_PATH
            t.dependency = DEPENDENCY_NAME
            t.version = version
            t.os_ids = {mac: 'darwin', linux: 'linux'}
            t.uri_template = "https://releases.hashicorp.com/terraform/<%= @version %>/terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>"
            t.file_name_template = "terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>"
          end
          RakeDependencies::Tasks::Extract.new do |t|
            t.type = :zip
            t.path = DEFAULT_PATH
            t.dependency = DEPENDENCY_NAME
            t.version = version
            t.os_ids = {mac: 'darwin', linux: 'linux'}
            t.file_name_template = "terraform_<%= @version %>_<%= @os_id %>_amd64<%= @ext %>"
          end
          RakeDependencies::Tasks::Fetch.new do |t|
            t.dependency = DEPENDENCY_NAME
          end
          Ensure.new do |t|
            t.version = version
          end
        end
      end
    end

    class Ensure < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      attr_accessor :name
      attr_accessor :version
      attr_accessor :path
      attr_accessor :clean_task
      attr_accessor :download_task
      attr_accessor :extract_task

      def initialize(*args, &task_block)
        @name = name || :ensure
        @version = DEFAULT_VERSION
        @path = DEFAULT_PATH
        @clean_task = scoped_task_name(:clean)
        @download_task = scoped_task_name(:download)
        @extract_task = scoped_task_name(:extract)

        define(args, &task_block)
      end

      private

      def scoped_task_name(task_name)
        Rake.application.current_scope.path_with_task_name(task_name)
      end

      def define(args, &task_block)
        desc "Ensure terraform is present"
        task name, *args do |_, task_args|
          task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block

          terraform_binary = path == DEFAULT_PATH ?
              DEFAULT_BINARY :
              File.join(path, "bin", "terraform")
          version_string = StringIO.new

          needs_fetch = true

          if File.exist?(terraform_binary)
            Lino::CommandLineBuilder.for_command(terraform_binary)
                .with_flag('-version')
                .build
                .execute(stdout: version_string)

            if version_string.string.lines.first =~ /#{version}/
              needs_fetch = false
            end
          end

          if needs_fetch
            Rake::Task[clean_task].execute
            Rake::Task[download_task].execute
            Rake::Task[extract_task].execute
          end
        end
      end
    end
  end
end
