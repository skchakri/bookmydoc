class Rack::Attack
  # Throttle login attempts
  throttle('login/ip', limit: 5, period: 60.seconds) do |req|
    if req.path == '/login' && req.post?
      req.ip
    end
  end

  # Throttle OTP verification attempts
  throttle('otp_verify/ip', limit: 3, period: 60.seconds) do |req|
    if req.path == '/verify_otp' && req.post?
      req.ip
    end
  end

  # Throttle OTP send attempts
  throttle('signup/ip', limit: 3, period: 300.seconds) do |req|
    if req.path == '/signup' && req.post?
      req.ip
    end
  end

  # Throttle general requests per IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  # Block suspicious requests
  blocklist('block_bad_user_agents') do |req|
    # Block requests from known bad user agents
    req.user_agent.present? && req.user_agent.match(/badbot|scraper/i)
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    [
      429,
      {'Content-Type' => 'text/html'},
      ['<html><body><h1>Rate Limit Exceeded</h1><p>Too many requests. Please try again later.</p></body></html>']
    ]
  end
end
