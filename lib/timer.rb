module Timer
  def timer(action = nil)
    start_time = Time.now
    yield
    elapsed = (Time.now - start_time)
    puts elapsed if action == :puts
    return elapsed
  end
  module_function :timer
end
