class Worker
  @queue = :ec

  def self.perform(name, props)
    fork do
      #exec("bash -l ./ec/v5/ec.sh")
      exec("ping google.com")
    end
  end
end
