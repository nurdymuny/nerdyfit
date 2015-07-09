Rails.application.config.middleware.use OmniAuth::Builder do

  ENV["GOOGLE_CLIENT_ID"] = 'xxx'
  ENV["GOOGLE_SECRET"] = 'xxx'

  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_SECRET"],
        scope: ['https://www.googleapis.com/auth/userinfo.email', 'https://www.googleapis.com/auth/fitness.activity.read', 'https://www.googleapis.com/auth/fitness.body.read'], access_type: 'offline', name: 'google'
end
