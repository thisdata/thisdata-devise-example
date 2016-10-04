Warden::Manager.on_request do |proxy|
  if proxy.request.get? && !proxy.request.original_fullpath.start_with?("/assets")
    payload = {
      ip: proxy.request.remote_ip,
      user_agent: proxy.request.user_agent,
      verb: 'page-view',
      object: {
        url: proxy.request.original_url
      }
    }
    if proxy.authenticated?
      payload[:user] = {
        id: proxy.user.send(ThisData.configuration.user_id_method)
      }
    end
    ThisData.track(payload)
  end
end

# Track when a user logs in.
# `after_set_user` is triggered the first time one of these happens during
#   a request: :authentication, :fetch (from session) and :set_user (when
#   manually set). We'll exclude :fetch.
Warden::Manager.after_set_user except: :fetch do |user, proxy, opts|
  user_payload = {
    id: user.send(ThisData.configuration.user_id_method)
  }
  user_payload[:name]   = user.send(ThisData.configuration.user_name_method)   if user.respond_to?(ThisData.configuration.user_name_method)
  user_payload[:email]  = user.send(ThisData.configuration.user_email_method)  if user.respond_to?(ThisData.configuration.user_email_method)
  user_payload[:mobile] = user.send(ThisData.configuration.user_mobile_method) if user.respond_to?(ThisData.configuration.user_mobile_method)


  payload = {
    ip: proxy.request.remote_ip,
    user_agent: proxy.request.user_agent,
    verb: 'log-in',
    user: user_payload
  }
  ThisData.track(payload)
end

# Track logouts
Warden::Manager.before_logout do |user, proxy, opts|
  user_payload = {
    id: user.send(ThisData.configuration.user_id_method)
  }
  user_payload[:name]   = user.send(ThisData.configuration.user_name_method)   if user.respond_to?(ThisData.configuration.user_name_method)
  user_payload[:email]  = user.send(ThisData.configuration.user_email_method)  if user.respond_to?(ThisData.configuration.user_email_method)
  user_payload[:mobile] = user.send(ThisData.configuration.user_mobile_method) if user.respond_to?(ThisData.configuration.user_mobile_method)


  payload = {
    ip: proxy.request.remote_ip,
    user_agent: proxy.request.user_agent,
    verb: 'log-out',
    user: user_payload
  }
  ThisData.track(payload)
end

#
# Extra for experts - you must override Devise's default SessionsController
#

# Track failed login
#
# To get the user, we must override the default SessionsController's
#   #auth_options method
#
# `before_failure` is a callback that runs just prior to the failure application
# being called. This callback occurs after PATH_INFO has been modified for the
# failure (default /unauthenticated)
Warden::Manager.before_failure do |env, opts|
  if opts[:action] == 'unauthenticated'

    # Try to grab some context about the user
    user_payload = {}
    if user = opts[:user]
      user_payload[:id]     = user.send(ThisData.configuration.user_id_method)
      user_payload[:name]   = user.send(ThisData.configuration.user_name_method)   if user.respond_to?(ThisData.configuration.user_name_method)
      user_payload[:email]  = user.send(ThisData.configuration.user_email_method)  if user.respond_to?(ThisData.configuration.user_email_method)
      user_payload[:mobile] = user.send(ThisData.configuration.user_mobile_method) if user.respond_to?(ThisData.configuration.user_mobile_method)
    elsif opts[:sign_in_params]
      user_payload.merge!(opts[:sign_in_params])
    end

    req = ActionDispatch::Request.new(env)

    payload = {
      ip: req.remote_ip,
      user_agent: req.user_agent,
      verb: 'log-in-denied',
      user: user_payload
    }
    ThisData.track(payload)
  end
end