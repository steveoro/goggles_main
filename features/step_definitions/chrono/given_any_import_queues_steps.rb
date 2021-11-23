# frozen_string_literal: true

# Uses @current_user
Given('there is a chrono recording request from the current_user with sibling rows') do
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
  json_request = File.read("#{GogglesDb::Engine.root}/spec/fixtures/req_lap_0.json")
  master_row = FactoryBot.create(:import_queue, user: @current_user, uid: 'chrono', request_data: json_request)

  # Prepare sibling rows:
  %w[req_lap_1 req_lap_2 req_lap_3].each do |fixture_name|
    json_request = File.read("#{GogglesDb::Engine.root}/spec/fixtures/#{fixture_name}.json")
    FactoryBot.create(
      :import_queue,
      user: @current_user, uid: "chrono-#{master_row.id}",
      request_data: json_request,
      import_queue: master_row
    )
  end
  expect(GogglesDb::ImportQueue.for_user(@current_user).count).to be >= 4
end
