class WelcomeController < ApplicationController
  require 'nerdyfit'

  before_action :fit_data, only: [:google_fit]
  before_action :ihealth_data, only: [:ihealth_data]

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

  def ihealth_data
    @result = User.get_ihealth_data(current_user)
  end

  def fit_data
    @data = User.get_fit_data (current_user.token)
  end
end
