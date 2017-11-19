linael :ping do
  db_value :ping_time

  on :ping, :ping do |msg|
    pong_channel msg.server_id, dest: msg.who
    ping_time.value = Time.now.to_i
    at(5.minutes.from_now) do
      exit!(0) if ping_time.value < 4.minutes.ago.to_i
    end
  end

  def no_ping_then_die
  end
end
