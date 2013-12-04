require 'sidekiq'
require 'eventmachine'

class Handler < EM::Connection
  def initialize(config)
    EM.add_timer(20) do
      Process.kill('KILL', get_pid)
    end
    @exp_id = config[:id]
    #@channel = config[:ch]
    super
  end

  def receive_data(data)
    puts "#{@exp_id} #{data.chomp} #{get_pid}"
    #@channel.push data.chomp
  end

  def unbind
    puts "ping died with exit status: #{get_status.exitstatus}"
  end
end

module ECService
  class Worker
    include Sidekiq::Worker

    def perform(name, props)
      EM.run do
        EM.popen("ping google.com", Handler, id: name, ch: @channel)
      end
    end
  end
end
