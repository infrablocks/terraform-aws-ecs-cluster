require 'rspec/core/rake_task'

require_relative 'lib/terraform'

Terraform::Tasks.install('0.8.6')

task :default => 'test:integration'

namespace :test do
  RSpec::Core::RakeTask.new(:integration) do
    ENV['AWS_REGION'] = 'eu-west-2'
  end
end
