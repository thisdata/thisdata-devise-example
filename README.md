# ThisData Devise example app

This is an example Rails app which uses Devise for authentication, and ThisData
to track events and provide login intelligence. 
You can use our Anomaly Detection APIs to enable better user experience & enhanced security in your application.

When you get it up and running, here's what your Audit Log will end up looking like:

![screen shot 2016-10-04 at 4 17 36 pm](https://cloud.githubusercontent.com/assets/342417/19061532/1fcd5e58-8a4e-11e6-8eca-264757a78bc6.png)

And if you enable end-user notification for suspicious activity, here's what your user might see:
![](https://cloud.githubusercontent.com/assets/342417/19061740/c253e5f6-8a4f-11e6-8d0c-c9156c994c21.png)


## Getting this in your own app:

If you're a TL;DR type person, the best bit is in [`lib/this_data/warden_hooks.rb`](https://github.com/thisdata/thisdata-devise-example/blob/master/lib/this_data/warden_hooks.rb):

```
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

... etc ...
```

But really, it's super simple to get going:

  1. Install the [`thisdata-ruby` gem](https://github.com/thisdata/thisdata-ruby), and follow its installation instructions
    - see [`config/this_data.rb`](https://github.com/thisdata/thisdata-devise-example/blob/master/config/initializers/this_data.rb) for an example configuration file
  1. Copy [`lib/this_data/warden_hooks.rb`](https://github.com/thisdata/thisdata-devise-example/blob/master/lib/this_data/warden_hooks.rb) in to your own project
  1. Add `require 'this_data/warden_hooks'` to [`config/initializers/devise.rb`](https://github.com/thisdata/thisdata-devise-example/blob/2b320ee127eb4f620a482f91228121846280def3/config/initializers/devise.rb#L26)

### If you want to track failed log-ins

If you haven't already extended `Devise::SessionsController`:

  1. Copy [`app/controllers/my_sessions_controller.rb`](https://github.com/thisdata/thisdata-devise-example/blob/master/app/controllers/my_sessions_controller.rb)
  1. In [`routes.rb`](https://github.com/thisdata/thisdata-devise-example/blob/master/config/routes.rb), change your `devise_for` line to look like
```
devise_for :users, controllers: { :sessions => "my_sessions" }
```

You can change the name of the controller if you wish.

If you have already extended `Devise::SessionsController`, copy the protected
`auth_options` method over into your controller.

### What do you get?!

This will enable tracking of

  - `log-in` - successful login events
  - `log-in-denied` - when someone fails to log in
    - if the email/username is correct, the corresponding User details are tracked
  - `log-out` - when the user logs out
  - `page-view` - each page viewed in your app, containing user information
   when they're logged in

### Want more?

If you've extended your Devise controllers, you should make sure to include
tracking for

  - `password-reset-request` - someone asked to reset their password
  - `password-reset` - a User reset their password
  - `password-reset-request`
  - `email-update`
  - `password-update`

If you support Two Factor Authentication:

  - `authentication-challenge`
  - `authentication-challenge-pass`
  - `authentication-challenge-fail`
  - `two-factor-disable`
  
And any other event you like! Read more: ["What events should I track?"](help.thisdata.com/docs/what-events-should-i-track)

---

This example app is based off the [RailsApps Devise example app](https://github.com/RailsApps/rails-devise)
Copyright ©2014-15 Daniel Kehoe. MIT License
