module LetterOpener
  class MainView < View

    attr_accessor :messages,
                  :attachments

    def subject
      @mail.subject
    end

    def from
      @from ||= Array(@mail['from']).join(", ")
    end

    def sender
      @sender ||= Array(@mail['sender']).join(", ")
    end

    def to
      @to ||= Array(@mail['to']).join(", ")
    end

    def cc
      @cc ||= Array(@mail['cc']).join(", ")
    end

    def bcc
      @bcc ||= Array(@mail['bcc']).join(", ")
    end

    def reply_to
      @reply_to ||= Array(@mail['reply-to']).join(", ")
    end

  end
end
