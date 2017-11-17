require 'weather-underground'
require 'ruby-units'

linael :weather do
  help [
    t.weather.help.description,
    t.weather.help.source,
    t.help.helper.line.white,
    t.help.helper.line.functions,
    t.weather.help.function.weather,
    t.weather.help.function.forecast,
    t.weather.help.function.location
  ]

  on_init do
    @location = {}
  end

  def weather_from(location)
    w = WeatherUnderground::Base.new.CurrentObservations(location)
    raise MessagingException, t.weather.not.location(location.delete("\r")) if w.temp_c == ""
    t.weather.act.weather(w.display_location.first.full, w.weather, w.temp_c, w.temp_f, w.wind_dir, Unit("#{w.wind_mph} mi/h").convert_to("km/h").round.to_s, w.wind_mph, w.pressure_mb, w.relative_humidity)
  end

  def forecast_from(location)
    w = WeatherUnderground::Base.new.CurrentObservations(location)
    f = WeatherUnderground::Base.new.TextForecast(location)
    result = t.weather.act.forecast.main w.display_location.first.full
    raise MessagingException, t.weather.not.location(location.delete("\r")) if w.temp_c == ""
    f.days.first(4).each do |d|
      result += t.weather.act.forecast.day d.title, d.text.gsub("&deg;", "°")
    end
    result
  end

  def local(user)
    raise MessagingException, t.weather.not.register(user) unless @location[user.downcase]
  end
  ["weather", "forecast"].each do |method|
    on :cmd, "#{method}_search".to_sym, /^!(#{method}|#{method[0]})\s/ do |msg, options|
      message_handler msg do
        if options.all.match?(/[A-Za-z]/)
          answer(msg, send("#{method}_from", options.all))
        else
          local(options.from_who)
          answer(msg, send("#{method}_from", @location[options.from_who.downcase]))
        end
      end
    end
  end

  on :cmd, :set_location, /^!location\s/ do |msg, options|
    @location[options.from_who.downcase] = options.all
    answer(msg, "Location is set for #{options.from_who}")
  end
end
