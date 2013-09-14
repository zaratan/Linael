# -*- encoding : utf-8 -*-

require 'weather-underground'
require 'ruby-units'

linael :weather do

  help [
    "A module for weather",
    "thx to http://www.wunderground.com",
    " ",
    "######Functions######",
    "!weather or !w [location]  => Current weather for location",
    "!forecast or !f [location] => 3 days forecast for location",
    "!location location         => register a location for your user, so you don't have to type it ;)"
  ]

  on_init do
    @location={}
  end

  define_method "weather_from" do |msg,location|
    w = WeatherUnderground::Base.new.CurrentObservations(location)
    if w.temp_c == ""
      answer(msg,"Where the hell is #{location.gsub("\r","")} ?!?")
      return nil
    end
    "Weather for #{w.display_location.first.full}: \u0002Condition\u000F: #{w.weather} #{w.temp_c}°C (#{w.temp_f}°F). \u0002Wind\u000F: From #{w.wind_dir} at #{Unit("#{w.wind_mph} mi/h").convert_to("km/h").round.to_s} (#{w.wind_mph} mi/h). \u0002Pressure\u000F: #{w.pressure_mb} mb. \u0002Humidity\u000F: #{w.relative_humidity}"
  end

  define_method "forecast_from" do |msg,location|
    w = WeatherUnderground::Base.new.CurrentObservations(location)
    f = WeatherUnderground::Base.new.TextForecast(location)
    result = "Forecast for #{w.display_location.first.full}: "
    if w.temp_c == ""
      answer(msg,"Where the hell is #{location.gsub("\r","")} ?!?")
      return nil
    end
    f.days.first(4).each do |d|
      result += "\u0002#{d.title}\u000F: #{d.text.gsub("&deg;","°")}. "
    end
    result
  end

  define_method "local" do |msg,user|
    unless @location[user.downcase]
      answer(msg,"No location registered for #{user}. Use !location to register your location")
      return false
    end
    return true
  end

  on :cmd, :weather_search, /^!(weather|w)\s/ do |msg,options|
    if options.all =~ /[A-Za-z]/
      answer(msg,weather_from(msg,options.all))
    else
      answer(msg,weather_from(msg,@location[options.from_who.downcase])) if local(msg,options.from_who)
    end
  end

  on :cmd, :weather_forecast, /^!(forecast|f)\s/ do |msg,options|
    if options.all =~ /[A-Za-z]/
      answer(msg,forecast_from(msg,options.all))
    else
      answer(msg,forecast_from(msg,@location[options.from_who.downcase])) if local(msg,options.from_who)
    end
  end

  on :cmd, :set_location, /^!location\s/ do |msg,options|
    @location[options.from_who.downcase] = options.all
    answer(msg,"Location is set for #{options.from_who}")
  end

end
