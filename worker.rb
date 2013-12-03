module ECService
  class Worker
    #include Sidekiq::Worker

    def perform(params)
      fork do
        exec("bash -l ./ec/v5/ec.sh")
      end
    end
  end
end
