class WorkingTime < ActiveRecord::Base
  belongs_to :place

  default_scope { order(:wday, :start_hours) }

  def humanized_time
    "" + WorkingTime.time_pairs[self.start_hours] +
      " - " + WorkingTime.time_pairs[self.end_hours]
  end

  class << self
    # in this model working day is 6a.m. - 6a.m.
    # 12-60 are stored in start_time and end_time integer fields
    # (6*2-(24+6)*2))
    def normalized_day_of_week_and_hour(time = time.now)
      wday = time.wday
      hour = time.hour * 2
      hour += 1 if time.min >= 30

      if hour < 12
        wday = (wday - 1) % 7
        hour += 24*2
      end

      [wday, hour]
    end

    def day_pairs
      {
        1 => "Monday",
        2 => "Tuesday",
        3 => "Wednesday",
        4 => "Thursday",
        5 => "Friday",
        6 => "Saturday",
        0 => "Sunday"
      }
    end

    def time_pairs
      @time_pairs if @time_pairs
      hash = {}
      (12..60).to_a.each do |val|
        hour = val / 2
        hour -= 24 if hour >= 24
        ampm = hour >= 12 ? "PM" : "AM"
        hour -= 12 if hour >= 12
        hour = 12 if hour == 0
        minute = val % 2 == 0 ? 0 : 30
        next_day = val >= 48

        hash[val] = "#{nn hour}:#{nn minute} #{ampm}#{next_day ? ' (next day)' : ''}"
      end

      @time_pairs = hash
    end

    protected

    def nn(i)
      if i < 10
        "0#{i}"
      else
        "#{i}"
      end
    end
  end
end
