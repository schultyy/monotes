require 'thor'

module Monotes
  module CLI
    class Application < Thor
      desc "login", "Login into GitHub"
      def login
        print "Username > "
        username = STDIN.gets.chomp
        print("Password > ")
        password = STDIN.noecho(&:gets).chomp

      end
    end
  end
end
