require 'monotes/app_directory'

module Monotes
  class BodyText
    include Monotes::AppDirectory
    FILENAME = "ISSUE_BODY_TEXT"

    def initialize(title)
      @title = title
    end

    def read
      File.read(path)
    end

    def flush
      File.delete(path)
    end

    def create_issue
      edit_success = system "vim #{path}"
      if edit_success
        body_text = read
        Monotes::Models::Issue.new(:title => @title, :body => body_text)
      else
        nil
      end
    end

    private
    def path
      File.join(app_path, FILENAME)
    end
  end
end
