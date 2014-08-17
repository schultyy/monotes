require 'thor'
require 'yaml'
require 'netrc'
require 'octokit'
require 'monotes/authenticator'
require 'monotes/models/issue'

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
        save_issues(repository, issues.map do |issue|
          Monotes::Models::Issue.new(issue).to_hash
        end)
      end

      desc "show REPOSITORY", "Show downloaded issues"
      def show(repository)
        folder = File.expand_path("~/.monotes")
        repo_id = split_repository_identifier(repository)
        abs_path = File.join(folder, repo_id[:username], "#{repo_id[:repository]}.yaml")
        issues = YAML.load_file(abs_path)
        issues.map do |issue|
          STDOUT.puts "#{issue.fetch(:number)} - #{issue.fetch(:title)}"
        end
      end

      desc "create TITLE", "Creates a new local issue"
      def create(title)
        folder = File.expand_path("~/.monotes")
        body_text = File.join(folder, "ISSUE_BODY_TEXT")
        edit_success = system "vim #{body_text}"
        if edit_success
          issue = Monotes::Models::Issue.new(:title => title, :body => issue_body_text)
          flush_issue_body_text
        end
      end

      private

      def flush_issue_body_text
        folder = File.expand_path("~/.monotes")
        body_text_path = File.join(folder, "ISSUE_BODY_TEXT")

        File.delete(body_text_path)
      end

      def issue_body_text
        folder = File.expand_path("~/.monotes")
        body_text_path = File.join(folder, "ISSUE_BODY_TEXT")
        File.read(body_text_path)
      end

      def save_issues(repository, issues)
        folder = File.expand_path("~/.monotes")
        if !File.directory?(folder)
          Dir.mkdir(folder)
        end
        repo_id = split_repository_identifier(repository)
        user_folder = File.join(folder, repo_id[:username])
        Dir.mkdir(user_folder) if !File.directory?(user_folder)
        File.open(File.join(user_folder, "#{repo_id[:repository]}.yaml"), "w") do |handle|
          handle.write(issues.to_yaml)
        end
      end

      def split_repository_identifier(repo)
        parts = repo.split('/')
        {
          username: parts.first,
          repository: parts.last
        }
      end

      def write_to_netrc(username, token)
        netrc_handle = Netrc.read
        netrc_handle["api.github.com"] = username, token
        netrc_handle.save
      end
    end
  end
end
