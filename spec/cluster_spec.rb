require 'spec_helper'

describe 'ECS Cluster' do
  include_context :terraform

  ecs_client = Aws::ECS::Client.new
  subject {
    ecs_client.describe_clusters({
      clusters: ["#{vars.component}-#{vars.deployment_identifier}-#{vars.cluster_name}"],
      include: ['SETTINGS']
    }).clusters[0]
  }

  it { should exist }

  context 'when container insights enabled' do
    before(:all) do
      reprovision(
          enable_container_insights: 'yes')
    end

    it 'has container insights enabled on the cluster' do
      expect(subject.settings[0][:name]).to(eq('containerInsights'))
      expect(subject.settings[0][:value]).to(eq('enabled'))
    end
  end

  context 'when container insights disabled' do
    before(:all) do
      reprovision(
          enable_container_insights: 'no')
    end

    it 'has container insights disabled on the cluster' do
      expect(subject.settings[0][:name]).to(eq('containerInsights'))
      expect(subject.settings[0][:value]).to(eq('disabled'))
    end
  end
end
