# frozen_string_literal: true

Given('there are more than {int} swimming_pools matching my query {string}') do |min_count, query_string|
  expect(GogglesDb::SwimmingPool.for_name(query_string).count).to be > min_count
end

Given('there are no more than {int} swimming_pools matching my query {string}') do |max_count, query_string|
  expect(GogglesDb::SwimmingPool.for_name(query_string).count).to be <= max_count
end

Given('there are no swimming_pools matching my query {string}') do |query_string|
  expect(GogglesDb::SwimmingPool.for_name(query_string).count).to be_zero
end
