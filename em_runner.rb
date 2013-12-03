require 'eventmachine'
require 'em-websocket'

#require 'omf_base/logging_helper'

class Handler < EM::Connection
  def initialize(config)
    @exp_id = config[:id]
    @channel = config[:ch]
    super
  end

  def receive_data(data)
    puts "#{@exp_id} #{data.chomp} #{get_pid}"
    @channel.push data.chomp
  end

  def unbind
    puts "ping died with exit status: #{get_status.exitstatus}"
  end
end

EM.run do
  @channel = EM::Channel.new
  100.times do |i|
    EM.popen("ping google.com", Handler, id: i, ch: @channel)
  end

  EM::WebSocket.start(host: "0.0.0.0", port: 8080) do |ws|
    ws.onopen do
      puts "WebSocket connection open"
      @channel.subscribe do |msg|
        ws.send msg
      end
    end

    ws.onclose do
      puts "Connection closed"
    end
  end
end

