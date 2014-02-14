require "erb"

module LetterOpener
  class View

    attr_accessor :url
    attr_reader :type

    def initialize(type, template_path, mail, part)
      @type = type
      @mail = mail
      @part = part
      @template_path = template_path
    end

    def content_type
      @part && @part.content_type || @mail.content_type
    end

    def body
      @body ||= begin
        body = (@part || @mail).decoded

        @mail.attachments.each do |attachment|
          body.gsub!(attachment.url, "attachments/#{attachment.filename}")
        end

        body
      end
    end

    def encoding
      body.respond_to?(:encoding) ? body.encoding : "utf-8"
    end

    def render
      ERB.new(template_content).result(binding)
    end

    def h(content)
      CGI.escapeHTML(content)
    end

    def auto_link(text)
      text.gsub(URI.regexp(%W[https http])) do |link|
        "<a href=\"#{ link }\">#{ link }</a>"
      end
    end

    private

      def template_content
        File.read(@template_path)
      end

  end
end
