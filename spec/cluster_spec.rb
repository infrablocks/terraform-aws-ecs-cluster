# frozen_string_literal: true

require 'spec_helper'

describe 'ECS Cluster' do
  subject(:ecs_cluster) do
    ecs_client.describe_clusters({
                                   clusters: ["#{vars.component}-" \
                                              "#{vars.deployment_identifier}-" \
                                              "#{vars.cluster_name}"],
                                   include: ['SETTINGS']
                                 }).clusters[0]
  end

  include_context 'terraform'

  it 'exists' do
    expect(ecs_cluster).not_to(be_nil)
  end

  context 'when container insights enabled' do
    before(:all) do
      reprovision(
        enable_container_insights: 'yes'
      )
    end

    it 'has container insights enabled on the cluster' do
      container_insights_setting = ecs_cluster.settings.find do |setting|
        setting[:name] == 'containerInsights'
      end

      expect(container_insights_setting[:value]).to(eq('enabled'))
    end
  end

  context 'when container insights disabled' do
    before(:all) do
      reprovision(
        enable_container_insights: 'no'
      )
    end

    it 'has container insights disabled on the cluster' do
      container_insights_setting = ecs_cluster.settings.find do |setting|
        setting[:name] == 'containerInsights'
      end

      expect(container_insights_setting[:value]).to(eq('disabled'))
    end
  end
end
