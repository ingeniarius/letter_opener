require "erb"

module LetterOpener
  class Composer

    def initialize(location, mail)
      @mail = mail
      @location = location
    end

    def compose!
      FileUtils.mkdir_p(@location)
      attachments = []
      if @mail.attachments.any?
        attachments_dir = File.join(@location, 'attachments')
        FileUtils.mkdir_p(attachments_dir)
        @mail.attachments.each do |attachment|
          filename = attachment.filename.gsub(/[^\w.]/, '_')
          path = File.join(attachments_dir, filename)

          unless File.exists?(path) # true if other parts have already been rendered
            File.open(path, 'wb') { |f| f.write(attachment.body.raw_source) }
          end

          attachments << [attachment.filename, "attachments/#{URI.escape(filename)}"]
        end
      end

      messages = []

      messages << View.new(:text_html, template_path("text_html.html.erb"), @mail, @mail.html_part) if @mail.html_part
      messages << View.new(:text_plain, template_path("text_plain.html.erb"), @mail, @mail.text_part) if @mail.text_part

      if messages.empty?
        type = (@mail.content_type =~ /html/) ? :text_html : :text_plain
        messages << View.new(type, template_path("#{type}.html.erb"), @mail, nil)
      end

      messages.each do |message|
        filename = "#{message.type}.html"
        filepath = destination_path(filename)
        message.url = filepath
        write(filepath, message.render)
      end

      main_view = MainView.new(:text_html, template_path("main.html.erb"), @mail, nil)
      main_view.messages = messages
      main_view.attachments = attachments

      css_filename = "letter_opener.css"
      write(destination_path(css_filename), File.read(template_path(css_filename)))
      write(url, main_view.render)
    end

    def url
      @url ||= destination_path("main.html")
    end

    private

      def destination_path(filename)
        File.join(@location, filename)
      end

      def template_path(filename)
        File.expand_path("../templates/#{filename}", __FILE__)
      end

      def write(path, content)
        File.open(path, 'w') { |f| f.write content }
      end

  end
end
