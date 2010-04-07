module HttpDoc

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
      controller
    end
    
  end
  
  module ActionDocParser
    
    def self.parse(doc, actions = [])
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
          if line =~ /\A\s*##(.*)/
            flush
          end
          if @toplevel and line =~ /(^|\s)class \w/
            flush
            @toplevel = false
          end
          if @controller and not @toplevel and line =~ /^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.*)/
            @controller.constants[$1] = $2
          end
          if line =~ /\A\s*#+\s?(.*)/
            @buffer << $1
            @buffer << "\n"
          else
            flush
          end
        end
      end
      flush
    end
    
    def flush
      if @buffer != ''
        if @toplevel
          @controller = ControllerDocParser.parse(@buffer)
          @toplevel = false
        elsif @controller
          ActionDocParser.parse(@buffer, @controller.actions)
        end
        @buffer = ''
      end
    end
    
    attr_reader :controller
    
    private
    
      def reset
        @controller = nil
        @buffer = ''
        @toplevel = true
      end
    
  end
  
end
