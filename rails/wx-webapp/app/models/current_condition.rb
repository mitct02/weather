require 'active_support'

class CurrentCondition < ActiveRecord::Base
  include WxUtils

  validates_uniqueness_of :location
  validates_presence_of   :location
  validates_length_of     :location, :maximum => 30
  validates_inclusion_of  :outside_humidity, :in => 1..100,
                          :allow_nil => true, :message => "invalid outside humidity"
  validates_inclusion_of  :inside_humidity, :in => 1..100,
                          :allow_nil => true, :message => "invalid inside humidity"
  validates_inclusion_of  :pressure, :in => 25..35,
                          :allow_nil => true, :message => "invalid pressure"
  validates_inclusion_of  :wind_direction, :in => 0..360,
                          :allow_nil => true, :message => "invalid wind direction"

  def wind_str
    return "unavailable" if self[:windspeed].nil?
    return "calm" if (self[:windspeed].eql?(0))
    return Direction.to_s(self[:wind_direction]) + " at " + windspeed.to_s + " mph"
  end
  
  def wind
    { :windspeed => self[:windspeed], :direction => self[:wind_direction] }
  end

#  class Event
#    read_attr :date, :value
#    def initialize(date, value)
#      @date = date
#      @value = value
#    end
#  end

  def gust
    start_tm = 10.minutes.ago.utc
    value = ArchiveRecord.maximum(:high_wind_speed, :conditions => "date > \'#{start_tm.to_s(:db)}\' and location = \'#{location}\'")
    value #todo build an Event object here
  end

  def gust_time
    a = ArchiveRecord.find(:first, :conditions => {:high_wind_speed => :gust, :location => location}, :order => "date desc")
    a.date
  end

  def last_rain
    a = ArchiveRecord.find(:first, :conditions => "rainfall > 0", :order => "date desc")
    if a.nil? then a = "01-01-1970" else a.date end
  end


  def twentyfour_hour_rain
    start_tm = 24.hours.ago.utc
    ArchiveRecord.sum(:rainfall, :conditions => "date >= \'#{start_tm.to_s(:db)}\' and location = \'#{location}\'")
  end

  def hourly_rain
    start_tm = 1.hour.ago.utc
    ArchiveRecord.sum(:rainfall, :conditions => "date >= \'#{start_tm.to_s(:db)}\' and location = \'#{location}\'")
  end

  def temp_trend
    if trend_record == nil or outside_temperature == trend_record.avgTemp then
      return nil
    else 
      outside_temperature > trend_record.avgTemp ? "Rising" : "Falling"
    end
  end
          
  def dewpoint_trend
    if trend_record == nil or dewpoint == trend_record.avgDewpoint then
      return nil
    else 
      dewpoint > trend_record.avgDewpoint ? "Rising" : "Falling"
    end
  end

  def bar_status
    if trend_record == nil or pressure == trend_record.avgPressure then
      return "Steady"
    else 
      pressure > trend_record.avgPressure ? "Rising" : "Falling"
    end
  end


  def outside_temperature_m
    return to_c(outside_temperature).round_with_precision(1)
  end

  def apparent_temp_m
    return to_c(calc_apparent_temp(outside_temperature, outside_humidity, windspeed)).round_with_precision(1)
  end

  def dewpoint_m
    return to_c(dewpoint).round_with_precision(1)
  end

  def extra_temp1_m
    return to_c(extra_temp1).round_with_precision(1)
  end


  def pressure_m
    return inches_of_hg_to_mb(pressure).round_with_precision(1)
  end

  def windspeed_m
    return mph_to_mps(windspeed).round_with_precision(1)
  end

  def rain_rate_m
    return inches_to_mm(rain_rate)
  end

  def is_raining
    if rain_rate.nil?
      return nil
    elsif rain_rate > 0.0
      return true
    else
      return false
    end
  end


          
  protected
    
  def trend_record
    @trend_record = PastSummary.find_by_location_and_period(location, :last_hour)
    @trend_record
  end

  def before_save
    # calculate metric and english dewpoints
    if  !outside_temperature.nil? and !outside_humidity.nil?
      dp = calc_dewpoint(outside_temperature, outside_humidity).round_with_precision(1)
      self.dewpoint = dp
      self.dewpoint_m = to_c(dp).round_with_precision(1)
    else
      self.dewpoint = self.dewpoint_m = nil
    end
                                  
    if  !outside_temperature.nil? and !outside_humidity.nil?
      at = calc_apparent_temp(outside_temperature, outside_humidity, windspeed) #.round_with_precision(1)
      self.apparent_temp = at
      self.apparent_temp_m = to_c(at).round_with_precision(1)
    else
      self.apparent_temp = self.apparent_temp_m = nil
    end

    if rain_rate.nil?
      self.is_raining = nil
    elsif rain_rate > 0.0
      self.is_raining = true
    else
      self.is_raining = false
    end

    self.windspeed_m = mph_to_mps(self.windspeed).round_with_precision(1) unless self.windspeed.nil?
    self.ten_min_avg_wind_m = mph_to_mps(self.ten_min_avg_wind).round_with_precision(1) unless self.ten_min_avg_wind.nil?
    self.rain_rate_m = inches_to_mm(self.rain_rate) unless self.rain_rate.nil?
    self.daily_rain_m = inches_to_mm(self.daily_rain) unless self.daily_rain.nil?
    self.monthly_rain_m = inches_to_mm(self.monthly_rain) unless self.monthly_rain.nil?
    self.yearly_rain_m = inches_to_mm(self.yearly_rain) unless self.yearly_rain.nil?
    self.storm_rain_m = inches_to_mm(self.storm_rain) unless self.storm_rain.nil?
    self.pressure_m = inches_of_hg_to_mb(self.pressure).round_with_precision(1) unless self.pressure.nil?
    self.outside_temperature_m = to_c(self.outside_temperature).round_with_precision(1) unless self.outside_temperature.nil?
    self.inside_temperature_m = to_c(self.inside_temperature).round_with_precision(1) unless self.inside_temperature.nil?
    
    return true
  end
end
