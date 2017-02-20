shared_context :terraform do
  include Awspec::Helper::Finder
  
  let(:variables) { RSpec.configuration }
end