module ApplicationHelper
  # Detect if the request is coming from Turbo Native (mobile app)
  # For testing: add ?mobile=true to URL
  def turbo_native_app?
    request.user_agent.to_s.match?(/Turbo Native/) || params[:mobile] == 'true'
  end

  # Hide content only for Turbo Native app
  def unless_turbo_native(&block)
    return if turbo_native_app?
    capture(&block)
  end
end
