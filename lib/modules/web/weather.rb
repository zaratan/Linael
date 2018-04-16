require 'weather-api'
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

  db_hash :locations

  def weather_from(location)
    w = Weather.lookup_by_location(location, Weather::Units::CELSIUS)
    t.weather.act.weather(w.title, w.text, w.condition.temp)
  rescue NoMethodError
    raise MessagingException, t.weather.not.location(location.delete("\r"))
  end

  def forecast_from(location)
    f = Weather.lookup_by_location(location, Weather::Units::CELSIUS)
    result = t.weather.act.forecast.main "#{f.location.city} #{f.location.region} #{f.location.country}"
    f.forecasts.first(4).each do |d|
      result += t.weather.act.forecast.day(d.day, "#{d.text}, #{d.low}°C / #{d.high}°C")
    end
    result
  rescue NoMethodError
    raise MessagingException, t.weather.not.location(location.delete("\r"))
  end

  def local(user)
    raise MessagingException, t.weather.not.register(user) unless locations[user.downcase]
  end

  ["weather", "forecast"].each do |method|
    on :cmd, "#{method}_search".to_sym, /^!(#{method}|#{method[0]})\s/ do |msg, options|
      message_handler msg do
        if options.all.match?(/[A-Za-z]/)
          answer(msg, send("#{method}_from", options.all))
        else
          local(options.from_who)
          answer(msg, send("#{method}_from", locations[options.from_who.downcase]))
        end
      end
    end
  end

  on :cmd, :set_location, /^!location\s/ do |msg, options|
    locations[options.from_who.downcase] = options.all
    answer(msg, "Location is set for #{options.from_who}")
  end
end
