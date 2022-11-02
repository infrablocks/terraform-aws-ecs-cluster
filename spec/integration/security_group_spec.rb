# frozen_string_literal: true

require 'spec_helper'

describe 'Security Group' do
  subject(:security_group) do
    security_group(
      "#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}"
    )
  end

  include_context 'terraform'

  it 'outputs the security group ID' do # integration
    expect(output_for(:harness, 'security_group_id'))
      .to(eq(security_group.id))
  end
end
