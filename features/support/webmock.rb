# frozen_string_literal: true

require 'webmock/cucumber'

WebMock.disable_net_connect!(
  allow_localhost: true,
  net_http_connect_on_start: true,
  allow: 'chromedriver.storage.googleapis.com'
)
puts '==> WebMock enabled <=='

Before('@api') do
  stub_request(:get, %r{.+/api/v3/tools/compute_score.+}i)
    .to_return(
      status: 200,
      body: {
        # (the returned values don't matter: they're just checked for positivity)
        timing: { minutes: 1, seconds: 24, hundredths: 36 },
        score: 901
      }.to_json
    )
  puts 'API stubbed'
end
