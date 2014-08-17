module Monotes
  module AppDirectory
    def app_path
      File.expand_path("~/.monotes")
    end
  end
end
