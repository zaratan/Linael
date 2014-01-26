module Linael

  class AdminChan < ActiveRecord::Base

    scope :joined, -> {where(joined: true)}

    def self.new_chan server_id, chan      
      create(name: chan, server_id: server_id.to_s)
    end

    def self.find_or_create(server_id, chan)
      chan = chan.downcase
      unless result_chan = find_by_server_id_and_name(server_id, chan)
        result_chan = new_chan(server_id, chan)
      end
      result_chan
    end

    def self.join server_id, chan
      chan = find_or_create(server_id, chan)
      chan.join_date = Time.now
      chan.joined = true
      chan.save
    end

    def self.part server_id,chan
      chan = find_or_create(server_id, chan)
      chan.part_date = Time.now
      chan.joined = false
      chan.save
    end

  end
end
