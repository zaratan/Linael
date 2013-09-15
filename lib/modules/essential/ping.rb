linael :ping do
  on :ping, :ping do |msg|
    pong_channel dest: msg.who
  end
end
