module Httpdoc

  module ControllerDocParser
    
    def self.parse(doc)
      controller = Controller.new
      if doc =~ /\A(.*?)^\s*@/m
        controller.description = $1.strip
      end
      doc.scan(/@title\s+(.*?)(^[@]|\z)/m).each do |s|
        controller.title = $1.strip
        break
      end
      doc.scan(/@url\s+(.*?)(?=^@|\z)/m) do
        controller.url = $1.strip
        break
      end
      controller
    end
    
  end
  
  module ActionDocParser
    
    def self.parse(name, doc, actions = [])
      action = Action.new
      if doc =~ /\A(.*?)^\s*@/m
        action.description = $1.strip
      end
      doc.scan(/@param\s+(.*?)(?:\s+(.*?))?(?=^\s*@|\z)/m) do
        param = Parameter.new
        param.name = $1
        param.description = $2
        action.parameters << param
      end
      doc.scan(/@status\s+(.*?)(?:\s+(.*?))?(?=^\s*@|\z)/m) do
        status = Status.new
        status.code = $1.strip
        status.description = $2.strip
        action.statuses << status
      end
      doc.scan(/@return\s+(.*?)(?=^@|\z)/m) do
        action.return = $1.strip
        break
      end
      doc.scan(/@short\s+(.*?)(?=^@|\z)/m) do
        action.short_description = $1.strip
        break
      end
      doc.scan(/@url\s+(.*?)(?=^@|\z)/m) do
        action.url = $1.strip
        break
      end
      action.url ||= name
      doc.scan(/@example\s*\n(.*?)(^\s*@end|\z)/m) do
        example = Example.new
        s = $1
        s.scan(/(^[\t ]*)@request\s+(.*?)(?=^\s*@|\z)/m) do
          padding, req = $1, $2
          example.request = req.split("\n").map { |line|
            line = line[padding.length..-1] || '' if line[0, padding.length] == padding
            line
          }.join("\n")
          break
        end
        s.scan(/(^[\t ]*)@response\s+(.*?)(?=^\s*@|\z)/m) do
          padding, res = $1, $2
          example.response = res.split("\n").map { |line|
            line = (line[padding.length..-1] || '') if line[0, padding.length] == padding
            line
          }.join("\n")
          break
        end
        action.examples << example
        break
      end
      actions << action
      actions
    end
    
  end
  
  class RubyCommentParser
    
    def initialize(file_name)
      @file_name = file_name
    end
    
    def parse
      reset
      File.open(@file_name) do |file|
        file.readlines.each do |line|
          case @state
            when :top
              case line
                when /\A\s*##(.*)/
                  @buffer << $1
                  @buffer << "\n"
                  @state = :class_doc
              end
            when :class_doc
              case line
                when /\A\s*#+\s?(.*)/
                  @buffer << $1
                  @buffer << "\n"
                when /(^|\s*)class \w/
                  unless @buffer.empty?                    
                    @controller = ControllerDocParser.parse(@buffer)
                    @buffer = ''
                  end                  
                  @state = :class_def
              end              
            when :class_def
              case line
                when /^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.*)/
                  if @controller
                    @controller.constants[$1] = $2
                  end
                when /\A\s*##(.*)/
                  @buffer << $1
                  @state = :method_def
              end
            when :method_def
              case line
                when /\A\s*#+\s?(.*)/
                  @buffer << $1
                  @buffer << "\n"
                when /\A\s*def ([^\s#\(]+)/
                  name = $1
                  unless @buffer.empty?
                    if @controller
                      ActionDocParser.parse(name, @buffer, @controller.actions)
                    end
                    @buffer = ''
                  end
                  @state = :class_def
                else
                  unless @buffer.empty?
                    if @controller
                      ActionDocParser.parse(nil, @buffer, @controller.actions)
                    end
                    @buffer = ''
                  end
                  @state = :class_def
              end
          end
        end
      end
      if @controller
        @controller.url ||= $1 if @file_name =~ /(\w+)_controller\./
      end
    end
    
    attr_reader :controller
    
    private
    
      def reset
        @controller = nil
        @buffer = ''
        @state = :top
      end
    
  end
  
end
