# frozen_string_literal: true

# Bot/crawler throttling. Disabled in test/dev unless RACK_ATTACK_ENABLED is set;
# limits are read from AppParameter :app settings and cached for 5 minutes.
module Rack
  # Rack Attack configuration and helpers.
  class Attack
    BOT_UA_PATTERN = /
      bot|crawler|spider|scraper|slurp|externalagent|externalhit|probe|headless|
      bytespider|ccbot|dotbot|semrush|gptbot|amazonbot|claudebot|curl|wget|
      python-requests|go-http-client|httpclient
    /ix
    EXEMPT_PATHS = %w[/up /robots.txt /favicon.ico].freeze
    EXEMPT_PREFIXES = %w[/assets /packs].freeze

    def self.exempt?(req)
      EXEMPT_PATHS.include?(req.path) || req.path.start_with?(*EXEMPT_PREFIXES)
    end

    def self.bot?(req)
      req.user_agent.to_s.match?(BOT_UA_PATTERN)
    end

    # => [max_bot_req, max_req_per_minute]
    def self.limits
      Rails.cache.fetch('rack_attack/throttle_limits', expires_in: 5.minutes) do
        [GogglesDb::AppParameter.max_bot_req, GogglesDb::AppParameter.max_req_per_minute]
      end
    end
  end
end

Rack::Attack.enabled = Rails.env.production? || ENV['RACK_ATTACK_ENABLED'].present?
Rack::Attack.cache.store = Rails.cache
Rack::Attack.throttled_response_retry_after_header = true

Rack::Attack.throttle('bot/ip/day', limit: ->(_req) { Rack::Attack.limits.first }, period: 1.day) do |req|
  req.ip if Rack::Attack.bot?(req) && !Rack::Attack.exempt?(req)
end

Rack::Attack.throttle('req/ip/min', limit: ->(_req) { Rack::Attack.limits.last }, period: 1.minute) do |req|
  req.ip unless Rack::Attack.exempt?(req)
end
