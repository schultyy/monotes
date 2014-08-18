require 'thor'
require 'yaml'
require 'netrc'
require 'octokit'
require 'monotes/authenticator'
require 'monotes/models/issue'
require 'monotes/app_directory'
require 'monotes/body_text'
require 'monotes/sync_list'

module Monotes
  module CLI
    class Application < Thor
      include Monotes::AppDirectory

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
        repo_id = split_repository_identifier(repository)
        abs_path = File.join(app_path, repo_id[:username], "#{repo_id[:repository]}.yaml")
        issues = YAML.load_file(abs_path)
        issues.map do |issue|
          STDOUT.puts "#{issue.fetch(:number)} - #{issue.fetch(:title)}"
        end
      end

      desc "create REPOSITORY TITLE", "Creates a new local issue"
      def create(repository, title)
        text = Monotes::BodyText.new(title)
        issue = text.create_issue
        sync_list.record(repository, issue)
        sync_list.save
      end

      private


      def sync_list
        @sync_list ||= Monotes::SyncList.new
      end

      def save_issues(repository, issues)
        if !File.directory?(app_path)
          Dir.mkdir(app_path)
        end
        repo_id = split_repository_identifier(repository)
        user_folder = File.join(app_path, repo_id[:username])
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
