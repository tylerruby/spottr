class WorkingTime < ActiveRecord::Base
  belongs_to :place

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
  end
end
