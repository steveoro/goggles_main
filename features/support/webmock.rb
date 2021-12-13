# frozen_string_literal: true

require 'webmock/cucumber'
WebMock.disable_net_connect!({
                               allow_localhost: true,
                               net_http_connect_on_start: true,
                               allow: 'chromedriver.storage.googleapis.com'
                             })

puts '==> WebMock enabled <=='
puts "\r\n[Steve] To prevent external connection errors by webdrivers updates run the dedicated update task periodically:"
puts "\r\n> RAILS_ENV=test rails webdrivers:chromedriver:update"

Given('the API tools\/compute_score endpoints are available') do
  stub_request(:get, %r{/api/v3/tools/compute_score\?.+}i)
    .to_return(
      status: 200,
      body: {
        # (the returned values don't matter: they're just checked for positivity)
        timing: { minutes: 1, seconds: 24, hundredths: 36 },
        score: 901
      }.to_json
    )
end
