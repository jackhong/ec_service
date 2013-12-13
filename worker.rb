require 'sidekiq'
require 'eventmachine'
require 'em-synchrony'
require './helper/redis'

class Handler < EM::Connection
  include ECService::RedisHelper

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
    EM.synchrony do
      redis.publish(ns(:log_events:, @exp_id), data.chomp)
      redis.set(ns(:status:, @exp_id), :started)
      redis.lpush(ns(:logs, @exp_id), data.chomp)
    end
  end

  def unbind
    puts "EC died with exit status: #{get_status.exitstatus}"
    status = get_status.exitstatus == 0 ? :finished : :died
    EM.synchrony do
      redis.set(ns(:status, @exp_id), status)
    end
    File.unlink(@oedl_path) if File.exist?(@oedl_path)
    EM.stop
  end
end

module ECService
  class Worker
    include Sidekiq::Worker
    sidekiq_options queue: :ec_v6_work, retry: false, backtrace: true

    def perform(name, oedl_path, props)
      ec_script_path = ENV['EC_PATH'] || "./ec/v6/ec.sh"
      cmd = "#{ec_script_path} #{oedl_path} -e #{name}"
      unless props.empty?
        cmd << " -- "
        props.each do |k, v|
          cmd << " --#{k} #{v}"
        end
      end
      EM.run do
        EM.popen(cmd, Handler, id: name, oedl_path: oedl_path)
      end
    end
  end
end
