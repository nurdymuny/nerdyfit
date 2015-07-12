class User < ActiveRecord::Base
  require 'rest-client'

  class << self
    def from_omniauth(auth_hash)
      user = find_or_create_by(userid: auth_hash['uid'], provider: auth_hash['provider'])
      user.name = auth_hash['info']['name']
      user.location = auth_hash['info']['location']
      user.image_url = auth_hash['info']['image']
      user.url = auth_hash['info']['urls'][user.provider.capitalize]
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
      url = "https://www.googleapis.com/fitness/v1/users/me/dataSources/derived:com.google.step_count.delta:com.google.android.gms:merge_step_deltas/datasets/#{time_from}-#{time_to}?fields=minStartTimeNs,maxEndTimeNs,point(startTimeNanos,endTimeNanos,value)"
      response    = RestClient.get url, {'Authorization': "Bearer #{user_token}"}
      data << JSON.parse(response.body)

      url = "https://www.googleapis.com/fitness/v1/users/me/dataSources/derived:com.google.weight:com.google.android.gms:merge_weight/datasets/#{time_from}-#{time_to}"
      response    = RestClient.get url, {'Authorization': "Bearer #{user_token}"}
      data << JSON.parse(response.body)
    end
  end

end
