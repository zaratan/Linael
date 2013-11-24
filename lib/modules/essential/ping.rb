# -*- encoding : utf-8 -*-
linael :ping do
  on :ping, :ping do |msg|
    pong_channel msg.server_id, dest: msg.who
  end
end
