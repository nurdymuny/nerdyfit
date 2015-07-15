class WelcomeController < ApplicationController
  require 'nerdyfit'

  before_action :require_data, only: [:google_fit]

  def index
  end

  def google_fit
    # Separate steps & weight data
    step_count, weight_count  = @data
    @result = []

    activites = ['walk', 'weight']
    activites.each do |activity|
      # For eash activity, calculate steps/weight (points) and get result in json format
      count_array = (activity == 'walk') ? step_count : weight_count
      point_counts = NerdyFit.calculate_points(count_array['point'])
      unless point_counts.nil?
        @result << NerdyFit.get_result(count_array, point_counts, activity)
      end
    end
  end

  def require_data
    @data = User.get_fit_data (current_user.token)
  end
end
