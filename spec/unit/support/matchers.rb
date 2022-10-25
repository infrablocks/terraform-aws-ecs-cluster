# frozen_string_literal: true

require 'json'
require 'set'

RSpec::Matchers
  .define(
    :a_policy_with_statement
  ) do |expected_statement, options = {}|
  def normalise(statement)
    %i[Resource NotResource Action NotAction]
      .each_with_object(statement) do |section, s|
      s[section] = s[section].to_set if s[section].is_a?(Array)
    end
  end

  match do |actual|
    return false unless actual

    expected_statement = normalise(expected_statement)
    policy = JSON.parse(actual, symbolize_names: true)
    statements = policy[:Statement]
    statement = statements.find do |target_statement|
      expected_statement <= normalise(target_statement)
    end
    present = !statement.nil?

    if present && options[:without_keys]
      options[:without_keys].each do |key|
        return false if statement.key?(key)
      end
    end

    present
  end
end
