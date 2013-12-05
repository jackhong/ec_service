require 'sidekiq'
require 'eventmachine'

class Handler < EM::Connection
  def initialize(config)
    super
    @exp_id = config[:id]
    @oedl_path = config[:oedl_path]
    if (t = config[:timeout])
      EM.add_timer(t) { Process.kill('KILL', get_pid) }
    end
  end

  def receive_data(data)
    puts "#{@exp_id} #{data.chomp} #{get_pid}"
    #@channel.push data.chomp
  end

  def unbind
    puts "EC died with exit status: #{get_status.exitstatus}"
    File.unlink(@oedl_path)
    EM.stop
  end
end

module ECService
  class Worker
    include Sidekiq::Worker
    sidekiq_options queue: :ec_v6_work, retry: false, backtrace: true

    def perform(name, oedl_path, props)
      EM.run do
        EM.popen("./ec/v6/ec.sh #{oedl_path} -e #{name}", Handler, id: name, oedl_path: oedl_path)
      end
    end
  end
end
