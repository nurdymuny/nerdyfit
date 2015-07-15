module NerdyFit
    def self.get_result(count_array, point_time, activity)
      # Get days with start_time & end_time
      start_time  = parse_nano_date(count_array['minStartTimeNs'])
      end_time    = parse_nano_date(count_array['maxEndTimeNs'])
      days        = get_days(start_time, end_time)

      result = []
      days.each do |day|
        result << json_output(day, point_time, activity)
      end
      result
    end

    def self.json_output(day, point_time, activity)
      steps_or_weight = 0
      aggregated = false
      point_time.each do |key, time|
        range = day[:start_time].to_i..day[:end_time].to_i

        if (range === time[:start_time_mili].to_i)
          aggregated = true if steps_or_weight != 0
          steps_or_weight += time[:value].to_i
        end
      end

      if activity == 'walk'
        activity_detail = {date: day[:end_time].strftime("%Y-%m-%d"), activity_type: activity, steps: steps_or_weight, aggregated: aggregated}
      else
        activity_detail = {date: day[:end_time].strftime("%Y-%m-%d"), activity_type: activity, weight: steps_or_weight, aggregated: aggregated}
      end
      activity_detail
    end

    def self.calculate_points(point)
      if point.nil?
        return
      else
        point_time = {}
        point.each_with_index do |step, index|
          start_time_mili = (step['startTimeNanos'].to_i)/1000000000
          point_time[index] = {"start_time_mili": "#{start_time_mili}", "value": step['value'].first.collect {|val| val[1]}.first}
        end
      end
      point_time
    end

    def self.get_days(first_date='', last_date='')
      days = []

      unless first_date.nil? || last_date.nil?
        total_days = (last_date - first_date).to_i
        first_date  = first_date + 24.hours

        total_days.times do |index|
          days << {start_time: first_date.beginning_of_day, end_time: first_date.end_of_day}
          first_date = first_date + 24.hours
        end
      end
      days
    end

    def self.parse_nano_date(nano_time)
      DateTime.parse(Time.strptime((nano_time.to_i/1000000).to_s, '%Q').utc.to_s)
    end
  end
