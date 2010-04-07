require "rubygems"
require "lib/http_doc/model"
require "lib/http_doc/parser"
require "lib/http_doc/rendering"

class HttpDoc < Thor
  
  desc "build PATH ...", "Generate documentation"
  method_option :base_url, 
    :type => :string,
    :desc => "Base URL for API URLs"
  def build(*paths)
    base_url = options[:base_url] || "http://localhost/"
    paths.each do |path|
      path = path.gsub(/\/$/, '')
      Dir.glob("#{path}/**/*_controller.rb").each do |fn|
        puts fn
        parser = ::HttpDoc::RubyCommentParser.new(fn)
        parser.parse
        if parser.controller
          r = ::HttpDoc::Rendering::SingleFileRenderer.new(:base_url => base_url)
          output_filename = File.basename(fn).gsub(/\.rb/, '')
          output_filename << ".html"
          File.open(output_filename, "w") { |f| f << r.render_controller(parser.controller) }
        end
      end
    end
  end
end
