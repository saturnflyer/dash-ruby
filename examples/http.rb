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
  metrics.include_recipe :ruby
  metrics.counter :foos, "Foos Rate" do
    MyApp.foos_last_minute
  end
  metrics.counter :other, 'Other' do
    rand(80)
  end
  metrics.time :do_something_time, :method => 'MyApp#do_something'
  metrics.counter :somethings, "Number of somethings", :incremented_by => 'MyApp#do_something'
end

app = MyApp.new

loop do
  sleep rand(3)
  app.do_something
  # if rand(3) == 1
  #   begin
  #     raise ArgumentError, 'This is an error'
  #   rescue => e
  #     Fiveruns::Dash.session.add_exception e
  #   end
  # end
end