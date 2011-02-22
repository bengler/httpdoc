module Httpdoc

  class Parameter
    attr_accessor :name
    attr_accessor :description
  end
  
  class Example
    attr_accessor :request
    attr_accessor :response
  end

  class Status
    attr_accessor :code
    attr_accessor :description
  end
  
  class Action
    def initialize
      @parameters = []
      @examples = []
      @statuses = []
    end
    
    attr_accessor :url
    attr_accessor :short_description
    attr_accessor :description
    attr_accessor :parameters
    attr_accessor :examples
    attr_accessor :statuses
    attr_accessor :return
  end
  
  class Controller
    def initialize
      @actions = []
      @constants = {}
    end

    attr_accessor :title
    attr_accessor :description
    attr_accessor :actions
    attr_accessor :constants
    attr_accessor :url
  end
  
end
