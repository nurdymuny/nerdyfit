class WelcomeController < ApplicationController

  def index
  end

  def google_fit
    @data = User.get_fit_data (current_user.token)

    step_count, weight_count  = @data

    @result = []
    unless step_count['point'].nil?
      point_time = {}
      step_count['point'].each_with_index do |step, index|
        start_time_mili = time_from_nano(step['startTimeNanos']).to_i
        point_time[index] = {"start_time_mili": "#{start_time_mili}", "steps": step['value'].first.collect {|val| val[1]}.first}
      end

      # Times are same for both activities
      start_time = time_from_nano(step_count['minStartTimeNs']).to_i
      mid_time = (time_from_nano(step_count['minStartTimeNs']) + 24.hours).to_i
      end_time = time_from_nano(step_count['maxEndTimeNs']).to_i

      first_day   = {start_time: start_time, end_time: mid_time}
      second_day  = {start_time: mid_time, end_time: end_time}
      days = [first_day, second_day]

      # Get Total Steps
      @result << get_result(days, point_time, 'walk')

      point_time = {}
      weight_count['point'].each_with_index do |weight, index|
        start_time_mili = time_from_nano(weight['startTimeNanos']).to_i
        point_time[index] = {"start_time_mili": "#{start_time_mili}", "weight": weight['value'].first.collect {|val| val[1]}.first}
      end

      # Get Total Weight
      @result << get_result(days, point_time, 'weight')
    end
  end

  private
    def get_result(days, point_time, activity)
      result = []
      days.each do |day|
        steps_or_weight = 0
        aggregated = false
        point_time.each do |key, time|
          range = day[:start_time].to_i..day[:end_time].to_i

          if (range === time[:start_time_mili].to_i)
            aggregated = true if steps_or_weight != 0
            steps_or_weight += time[:steps].to_i if activity == 'walk'
            steps_or_weight += time[:weight].to_i if activity == 'weight'
          end
        end

        if activity == 'walk'
          activity_detail = {date: Time.strptime(day[:end_time].to_s, '%Q').utc, activity_type: 'walk', steps: steps_or_weight, aggregated: aggregated}
        else
          activity_detail = {date: Time.strptime(day[:end_time].to_s, '%Q').utc, activity_type: 'weight', weight: steps_or_weight, aggregated: aggregated}
        end
        result << activity_detail
      end
      result
    end

    def time_from_nano(time)
      Time.strptime((time.to_i/1000000).to_s, '%Q').utc
    end
end
