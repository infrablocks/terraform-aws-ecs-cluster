require 'rake'
require 'rake/tasklib'
require 'rake_dependencies'
require 'ruby_terraform'
require 'net/http'
require 'zip'
require 'fileutils'
require 'lino'

require_relative 'paths'

module Terraform
  include RubyTerraform

  RubyTerraform.configure do |config|
    config.binary = Paths.from_project_root_directory(
        'vendor', 'terraform', 'bin', 'terraform')
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
