class User < ActiveRecord::Base
  require 'rest-client'

  class << self
    def from_omniauth(auth_hash)
      user = find_or_create_by(userid: auth_hash['uid'], provider: auth_hash['provider'])
      user.name = auth_hash['info']['name']
      user.location = auth_hash['info']['location']
      user.image_url = auth_hash['info']['image']
      user.url = auth_hash['info']['urls'][user.provider.capitalize] unless auth_hash['info']['urls'].nil?
      user.token = auth_hash.credentials.token
      # user.refresh_token = access_token.credentials.refresh_token
      user.save!
      user
    end

    def get_fit_data(user_token)
      data = []
      current_time = DateTime.now.utc
      time_from = current_time.strftime('%Q').to_i*1000000
      time_to   = (current_time - 48.hours).strftime('%Q').to_i*1000000

      urls = [
        "https://www.googleapis.com/fitness/v1/users/me/dataSources/derived:com.google.step_count.delta:com.google.android.gms:merge_step_deltas/datasets/#{time_from}-#{time_to}?fields=minStartTimeNs,maxEndTimeNs,point(startTimeNanos,endTimeNanos,value)",
        "https://www.googleapis.com/fitness/v1/users/me/dataSources/derived:com.google.weight:com.google.android.gms:merge_weight/datasets/#{time_from}-#{time_to}"
      ]

      urls.each do |url|
        data << response_from_fit_storage(url, user_token)
      end
      data
    end

    def get_ihealth_data(user)
      current_time = DateTime.now.utc
      start_time = current_time.strftime('%s').to_i
      end_time   = (current_time - 48.hours).strftime('%s').to_i

      sc = 'c018742e716f497fac460c59fde83dfb'
      sv = '5a164755340f41d99f39dd2be34ae723'

      url = "https://api.ihealthlabs.com:8443/openapiv2/user/#{user.userid}/activity.json/?client_id=#{ENV['IHEALTH_CLIENT_ID']}&client_secret=#{ENV['IHEALTH_CLIENT_SECRET']}&access_token=#{user.token}&sc=#{sc}&sv=#{sv}"
      response    = RestClient.get url
      JSON.parse(response.body)
    end

    def response_from_fit_storage(url, user_token)
      response    = RestClient.get url, {'Authorization': "Bearer #{user_token}"}
      JSON.parse(response.body)
    end
  end

end
