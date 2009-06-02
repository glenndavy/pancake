module Pancake
  class Stack
    include Rack::Router::Routable
    extend Middleware
    extend Hooks::OnInherit
    extend Hooks::InheritableInnerClasses
  
    def self.initialize_stack
      raise "Application root not set" if roots.empty?
      
      # Run any :init level bootloaders for this stack
      self::BootLoader.run!(:only => {:level => :init})
      
      roots.each do |root|  
        # Load the App
        Dir["#{root}/app/**/*.rb"].each{|f| require f if File.exists?(f)}
      
        # Load the router
        require "#{root}/config/router" if File.exists?("#{root}/config/router")
      end
      @initialized = true
    end # initiailze stack
      
    def self.initialized?
      !!@initialized
    end
    
    def self.roots
      configuration.roots
    end
  
    def this_stack
      self.class
    end
    
    # Construct a stack using the application, wrapped in the middlewares
    # :api: public
    def self.stack(opts = {}, &block)
      the_app = method(:initialize).arity == 1 ? new(opts, &block) : new(&block)
      mwares = middlewares
      
      # We build the router first then add the middleware then the app at the bottom
      app = new_app_instance
      
      stack = mwares.reverse.inject(app) do |app, m|
        m.middleware.new(app, m.opts)
      end
      stack
            
      # Wrap the stack in the router
      ### HERE's WHERE WE END FOR THE NIGHT
    end # stack

  end # Stack
end # Pancake