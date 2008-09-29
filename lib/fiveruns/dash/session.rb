module Fiveruns::Dash
    
  class Session
    
    attr_reader :configuration, :reporter
    def initialize(configuration)
      @configuration = configuration
    end
    
    def start(background = true, &block)
      reporter.start(background, &block)
    end
    
    def exceptions
      @exceptions ||= []
    end
    
    # Trace and send metric collection
    def trace
      Thread.current[:trace] = ::Fiveruns::Dash::Trace.new
      result = yield
      reporter.send_trace(Thread.current[:trace])
      Thread.current[:trace] = nil
      result
    end
    
    def add_exception(exception, sample=nil)
      exception_recorder.record(exception, sample)
    end
    
    def info
      {
        :recipes => recipe_metadata,
        :metric_infos => metric_metadata
      }
    end
    
    def recipe_metadata
      configuration.recipes.inject([]) do |recipes, recipe|
        recipes << recipe.info
      end
    end
    
    def metric_metadata
      configuration.metrics.inject([]) do |metrics, metric|
        metrics << metric.info
      end
    end
    
    def reset
      exception_recorder.reset
      configuration.metrics.each(&:reset)
    end
    
    def data
      configuration.metrics.map { |metric| metric.data }.flatten
    end
    
    def exception_data
      exception_recorder.data
    end
    
    def exception_recorder
      @exception_recorder ||= ExceptionRecorder.new(self)
    end
    
    def reporter
      @reporter ||= Reporter.new(self)
    end
    
  end
      
end