# -*- encoding : utf-8 -*-
class Struct
  def to_map
    map = Hash.new
    self.members.each do |m| 
      map[m]= if self[m].kind_of? String
                self[m].force_encoding("UTF-8") 
              else
                self[m]
              end
    end
    map
  end

  def to_json(*a)
    to_map.to_json(*a)
  end
end
