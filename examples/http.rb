require File.dirname(__FILE__) << "/example_helper"

class MyApp
  
  def self.foos_last_minute
    rand(80)  
  end
  
  def do_something
    sleep 0.01
  end
  
end

dash do |metrics|
  metrics.counter :foos, "BAR!" do
    MyApp.foos_last_minute
  end
  metrics.time 'MyApp#do_something'
end

app = MyApp.new

loop do
  sleep rand(3)
  app.do_something
  begin
    klasses = [ArgumentError, StandardError, RuntimeError]
    messages = ['foo did bar', 'bar did baz', 'baz did quux']
    if rand(6) == 3
      klass = klasses[rand(klasses.size)]
      message = messages[rand(messages.size)]
      puts "EXCEPTION! #{klass} #{message}"
      raise klass, message
    end
  rescue Exception => e
    Fiveruns::Dash.session.add_exception e
  end
end