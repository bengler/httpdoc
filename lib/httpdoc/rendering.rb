require "uri"
require "erb"
require "redcloth"

module Httpdoc
  module Rendering

    class UndefinedVariableError < Exception
      def initialize(name)
        super("Undefined variable #{name}")
        @name = name
      end
      attr_reader :name
    end
  
    class UndefinedConstantError < Exception
      def initialize(name)
        super("Undefined constant #{name}")
        @name = name
      end
      attr_reader :name
    end

    class ControllerContext
      
      def initialize(renderer, controller)
        @renderer = renderer
        @controller = controller
      end
      
      def h(s)
        s ||= ''
        return s.gsub(/#\{(.*)\}/) {
          name = $1
          case name
            when /^[A-Z0-9_]+$/
              value = @controller.constants[name]
              raise UndefinedConstantError.new(name) unless value
              value = eval(value)
            when "base_url"
              value = base_url.gsub(/\/$/, '')
            else
              raise UndefinedVariableError, name
          end
          value
        }
      end
      
      def doc_fragment_to_html(s)
        s = s.gsub("\n", ' ')
        RedCloth.new(s).to_html
      end
            
      def expand_url_with_subtitutions(url)
        url = [base_url, url].join("/") unless url =~ /^\//
        return URI.join(@renderer.base_url, url).to_s.gsub(/:([\w_]+)/, '<strong>&lt;\1&gt;</strong>')
      end
      
      def base_url
        controller_url = @controller.url
        controller_url ||= "/"
        return URI.join(@renderer.base_url, controller_url).to_s
      end
      
      def escape_html(h)
        return nil unless h
        h = h.dup
        h.gsub!("&", "&amp;")
        h.gsub!("<", "&lt;")
        h.gsub!(">", "&gt;")
        h.gsub!("\n", "<br/>")
        h
      end
      
      def format_request(req)
        envelope, body = req.split("\n\n")
        lines = envelope.split("\n")
        first_line, header_lines = lines[0], (lines[1..-1] || [])
        result = "<div class='request'>"
        result << "<strong class='request_first_line'>#{h(first_line)}</strong><br/>"
        result << header_lines.map { |h|
          name, value = h.split(":\s*")
          "<span class='request_header_line'><strong class='request_header_name'>#{escape_html(name)}" <<
            "</strong>: <span class='request_header_value'>#{escape_html(value)}</span></span>"
        }.join("<br/>")
        if body and body != ''
          result << "<br/>"
          result << "<div class='request_body'>#{escape_html(body.strip)}</div>"
        end
        result << "</div>"
        result
      end

      def format_response(res)
        envelope, body = res.split("\n\n")
        lines = envelope.split("\n")
        first_line, header_lines = lines[0], (lines[1..-1] || [])
        result = "<div class='response'>"
        result << "<strong class='response_first_line'>#{h(first_line)}</strong><br/>"
        result << header_lines.map { |h|
          name, value = h.scan(/(.+):\s*(.+)/)[0]
          "<span class='response_header_line'><strong class='response_header_name'>#{escape_html(name)}" <<
            "</strong>: <span class='response_header_value'>#{escape_html(value)}</span></span>"
        }.join("<br/>")
        if body and body != ''
          result << "<br/><br/>"
          result << "<div class='response_body'>#{escape_html(body)}</div>"
        end
        result << "</div>"
        result
      end
      
      def get_binding
        return binding
      end
      
      attr_reader :controller
      
    end

    class SingleFileRenderer
      
      def initialize(options = {})
        @base_url = options[:base_url]
        @base_url ||= 'http://example.com/'
      end
      
      def render_controller(controller)
        %w(erb).each do |extension|
          template_file_name = "#{@template_name}"
          template_file_name = "#{template_file_name}.#{extension}" unless template_file_name =~ /#{Regexp.escape(extension)}$/
          unless File.exist?(template_file_name)
            possible_template_file_name = File.join(File.dirname(__FILE__), "templates/#{template_file_name}")
            if File.exist?(possible_template_file_name)
              template_file_name = possible_template_file_name
            end
          end
          template_content = File.read(template_file_name)
          context = ControllerContext.new(self, controller)
          erb = ERB.new(template_content, nil, "-")
          return erb.result(context.get_binding)
        end
      end
      
      def find_template(name)
        %(erb).each do |extension|
        end
      end
      
      attr_reader :base_url
      attr_accessor :template_name
      
    end
    
  end
end
