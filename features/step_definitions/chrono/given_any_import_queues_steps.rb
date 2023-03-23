# frozen_string_literal: true

# Creates 3x ImportQueue fixture rows
# Uses @current_user
Given('there is a chrono recording request from the current_user with sibling rows') do
  expect(@current_user).to be_a(GogglesDb::User).and be_valid
  array_of_requests = JSON.parse(File.read('spec/fixtures/3x_swimmer-142_chrono.json'))
  # ****************** TODO: after DB engine update, use this instead: ***************************
  # array_of_requests = JSON.parse(File.read("#{GogglesDb::Engine.root}/spec/fixtures/3x_swimmer-142_chrono.json"))

  master_row = FactoryBot.create(
    :import_queue,
    user: @current_user, uid: 'chrono',
    request_data: array_of_requests.pop.to_json,
    import_queue: nil
  )

  array_of_requests.each do |fixture_hash|
    FactoryBot.create(
      :import_queue,
      user: @current_user, uid: "chrono-#{master_row.id}",
      request_data: fixture_hash.to_json,
      import_queue: master_row
    )
  end

  expect(GogglesDb::ImportQueue.for_user(@current_user).count).to be >= 3
end
