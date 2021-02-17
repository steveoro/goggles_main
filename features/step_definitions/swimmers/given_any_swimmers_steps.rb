# frozen_string_literal: true

Given('there are > {int} swimmers matching my query {string}') do |min_count, query_string|
  expect(GogglesDb::Swimmer.for_name(query_string).count).to be > min_count
end

Given('there are <= {int} swimmers matching my query {string}') do |max_count, query_string|
  expect(GogglesDb::Swimmer.for_name(query_string).count).to be <= max_count
end
