Rails.application.config.middleware.use OmniAuth::Builder do

  ENV["GOOGLE_CLIENT_ID"] = '1071864229687-bi61a02ongoe0r8e0o0qh4ms1bg7ocr9.apps.googleusercontent.com'
  ENV["GOOGLE_SECRET"] = 'aaB7teOKllQAXu5abJEY2SM-'

  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_SECRET"],
        scope: ['https://www.googleapis.com/auth/userinfo.email', 'https://www.googleapis.com/auth/fitness.activity.read', 'https://www.googleapis.com/auth/fitness.body.read'], access_type: 'offline', name: 'google'

  ENV["IHEALTH_CLIENT_ID"] = '567dc88b7347482ab1ba13d9e3ae82f9'
  ENV["IHEALTH_CLIENT_SECRET"] = 'bb856143cb0f4f839ec8c0c5ddfd4f3c'

  provider :ihealth, ENV["IHEALTH_CLIENT_ID"], ENV["IHEALTH_CLIENT_SECRET"], name: 'ihealth'
end
