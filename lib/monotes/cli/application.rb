require 'thor'

module Monotes
  module CLI
    class Application < Thor
      desc "login", "Login into GitHub"
      def login
        puts "logging in"
      end
    end
  end
end
