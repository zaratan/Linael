require 'r18n-desktop'

class Time

  include R18n::Helpers

  def ago
    sec = (Time.now - self).round 
    sec = 1 if sec == 0

    mm, ss = sec.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)

    result = [t.day(dd),t.hour(hh),t.minute(mm),t.second(ss)]
    result.delete("")
    result.join(", ").gsub(/(, )([^,]*)$/) {|s| " #{t.and} #{$2}"} + " #{t.ago}"

  end

end
