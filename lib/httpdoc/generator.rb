module Httpdoc
  
  class Generator
    
    attr_accessor :base_url
    attr_accessor :output_directory
    attr_accessor :input_paths
    attr_accessor :template_name
    
    def generate!
      file_names = @input_paths.map { |path|
        path = path.gsub(/\/$/, '')
        if File.file?(path)
          path
        else
          Dir.glob("#{path}/**/*_controller.rb")
        end
      }.flatten
      file_names.each do |file_name|
        parser = RubyCommentParser.new(file_name)
        parser.parse
        if parser.controller
          renderer = Rendering::SingleFileRenderer.new(:base_url => @base_url)
          renderer.template_name = @template_name
          output_filename = File.join(@output_directory, File.basename(file_name).gsub(/\.rb/, ''))
          output_filename << ".html"
          File.open(output_filename, "w") do |file|
            file << renderer.render_controller(parser.controller)
          end
        end
      end      
    end
    
  end

end
