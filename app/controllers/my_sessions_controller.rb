class MySessionsController < Devise::SessionsController

  protected

    # Extend Devise's basic auth_options Hash to add additional context about
    # the user. This makes it available to our Warden hooks.
    #
    # Returns a Hash
    def auth_options
      # Use Devise's first authentication method (e.g. email or username) to
      # get the sign in parameter
      authn_method = serialize_options(resource)[:methods].first
      authn_value  = sign_in_params[authn_method]

      # Look for a user matching that email/username
      user = resource_class.find_for_authentication(authn_method => authn_value)

      super.merge(
        sign_in_params: sign_in_params.except("password"),
        user: user
      )
    end

end