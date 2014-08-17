require 'thor'
require 'yaml'
require 'netrc'
require 'octokit'
require 'monotes/authenticator'

module Monotes
  module CLI
    class Application < Thor
      desc "login", "Login into GitHub"
      def login
        print "Username > "
        username = STDIN.gets.chomp
        print "Password > "
        password = STDIN.noecho(&:gets).chomp
        puts "\n"
        authenticator = Monotes::Authenticator.new(Octokit::Client)
        oauth_token = authenticator.get_oauth_token(username, password) do
          print "Two-Factor token > "
          STDIN.gets.chomp
        end
        write_to_netrc(username, oauth_token.token)
      end

      desc "download REPOSITORY", "Download issues for a repository"
      def download(repository)
        puts "Downloading issues for #{repository}..."
        issues = Octokit.list_issues(repository)
        save_issues(repository, issues.map{|i|i.to_hash})
      end

      desc "show REPOSITORY", "Show downloaded issues"
      def show(repository)
        folder = File.expand_path("~/.monotes")
        abs_path = File.join(folder, "#{repository}.yaml")
        issues = YAML.load_file(abs_path)
        issues.map do |issue|
          STDOUT.puts issue.fetch(:title)
        end
      end

      private
      def save_issues(repository, issues)
        folder = File.expand_path("~/.monotes")
        if !File.directory?(folder)
          Dir.mkdir(folder)
        end
        repository_name = repository.split('/').last
        File.open(File.join(folder, "#{repository_name}.yaml"), "w") do |handle|
          handle.write(issues.to_yaml)
        end
      end

      def write_to_netrc(username, token)
        netrc_handle = Netrc.read
        netrc_handle["api.github.com"] = username, token
        netrc_handle.save
      end
    end
  end
end
