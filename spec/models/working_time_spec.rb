require 'rails_helper'

describe WorkingTime do
  describe "normalized_day_of_week_and_hour" do
    let (:monday_8_40_am) { Time.new(2014, 11, 10, 8, 40) }
    let (:sunday_4_20_am) { Time.new(2014, 11, 9, 4, 20) }

    it "returns [6, 2*24+2*4] for sunday 4:20 am" do
      result = WorkingTime.normalized_day_of_week_and_hour(sunday_4_20_am)
      expect(result).to eq([6,2*24+2*4])
    end

    it "returns [1, 2*8+1] for monday 8:40 am" do
      result = WorkingTime.normalized_day_of_week_and_hour(monday_8_40_am)
      expect(result).to eq([1, 2*8+1])
    end
  end

  describe "time_pairs" do
    it "test" do
      WorkingTime.time_pairs.each_pair do |k, v|
        puts "#{k} => #{v}"
      end
    end
  end
end
