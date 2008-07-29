require 'dash/typable'

module Fiveruns::Dash
      
  class Metric
    include Typable
    
    attr_reader :name, :description, :options
    attr_accessor :info_id
    def initialize(name, *args, &block)
      @name = name.to_s
      @options = args.extract_options!
      @description = args.shift || @name.titleize
      @operation = block
    end
    
    def info
      {name => {:data_type => self.class.metric_type, :description => description}}
    end
    
    def data
      if info_id
        value_hash.update(:metric_info_id => info_id)
      else
        raise NotImplementedError, "No info_id assigned for #{self.inspect}"
      end
    end

    #######
    private
    #######
    
    def value_hash
      {:value => @operation.call}
    end
    
  end
  
  class TimeMetric < Metric
    
    def initialize(*args)
      super(*args)
      reset
      install_hook
    end
    
    #######
    private
    #######
    
    def value_hash
      returning(:value => @time, :invocations => @invocations) do
        reset
      end
    end
    
    def reset
      @invocations = @time = 0
    end

    def install_hook
      if methods_to_instrument.blank?
        raise ArgumentError, "Must set :method or :methods option for `#{@name}` time metric"
      end
      methods_to_instrument.each do |meth|
        instrument meth do |obj, time, *args|
          @invocations += 1
          @time += time
        end
      end
    end
    
    def methods_to_instrument
      @methods_to_instrument ||= Array(@options[:method]) + Array(@options[:methods])
    end
    
  end
      
  class CounterMetric < Metric
  end
  
  class PercentageMetric < Metric
  end
  
  class AbsoluteMetric < Metric
  end
      
end