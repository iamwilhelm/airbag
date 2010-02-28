# caches the result of a method into a local variable.  Can only use
# on methods that take no arguments.  The memoized function will take
# on argument called "reload".  Set to true if want to reload
module Memoize
  def self.included(base)
    base.extend(Memoize::ClassMethods)
  end
  
  module ClassMethods
    def memoize(method_name, options = {})
      alias_method "original_#{method_name}", method_name
      define_method(method_name) do |*args|
        reload = args ? args.pop : false
        value = if (reload == true || instance_variable_get("@#{method_name}").nil?)
                  send("original_#{method_name}")
                else
                  instance_variable_get("@#{method_name}")
                end
        instance_variable_set("@#{method_name}", value)        
      end
      
    end
  end
end

if __FILE__ == $0

  def timer
    start_time = Time.now
    yield
    puts "#{Time.now - start_time} secs elapsed"
  end

  # TODO turn memoize example into a test
  class Foo
    include Memoize
    
    def expensive
      sleep(2)
      return 42
    end
    memoize :expensive

  end

  foo = Foo.new
  timer do
    puts "result 1: #{foo.expensive}"
    puts "It's slow the first time around to warm up cache"
  end
  puts
  timer do
    puts "result 2: #{foo.expensive}"
    puts "This time, it's cached so it's fast"
  end
  puts
  timer do
    puts "result 2: #{foo.expensive(true)}"
    puts "This time, it's slow, because we reloaded"
  end

end
