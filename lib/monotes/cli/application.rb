require 'thor'
require 'yaml'
require 'netrc'
require 'octokit'
require 'monotes/authenticator'
require 'monotes/issue_download'
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
        downloader = Monotes::IssueDownload.new(Octokit)
        issues = downloader.download(repository)
        save_issues(*split_repository_identifier(repository), issues.map do |issue|
          issue.to_hash
        end)
      end

      desc "show REPOSITORY", "Show downloaded issues"
      def show(repository)
        username, repository = split_repository_identifier(repository)
        issues = load_issues(repository, username)
        issues.map do |issue|
          STDOUT.puts "#{issue.fetch(:number)} - #{issue.fetch(:title)}"
        end
      end

      desc "create REPOSITORY TITLE", "Creates a new local issue"
      def create(repository, title)
        text = Monotes::BodyText.new(title)
        issue = text.create_issue
        username, repository = split_repository_identifier(repository)
        issues = load_issues(repository, username)
        issues << issue.to_hash
        save_issues(username, repository, issues)
      end

      desc "sync REPOSITORY", "Synchronizes local issues with GitHub"
      def sync(repository)
        username, repo_name = split_repository_identifier(repository)
        issues = load_issues(repo_name, username).map { |i| Monotes::Models::Issue.new(i) }
        adapter = Octokit::Client.new(netrc: true)
        sync_list = Monotes::SyncList.new(list: issues, repo: repository, adapter: adapter)
        sync_list.sync do |issue|
          puts "Synced issue #{issue.title}"
        end
      end

      private

      def load_issues(repository, username)
        abs_path = File.join(app_path, username, "#{repository}.yaml")
        YAML.load_file(abs_path)
      end

      def save_issues(username, repository, issues)
        if !File.directory?(app_path)
          Dir.mkdir(app_path)
        end
        user_folder = File.join(app_path, username)
        Dir.mkdir(user_folder) if !File.directory?(user_folder)
        File.open(File.join(user_folder, "#{repository}.yaml"), "w") do |handle|
          handle.write(issues.to_yaml)
        end
      end

      def split_repository_identifier(repo)
        repo.split('/')
      end

      def write_to_netrc(username, token)
        netrc_handle = Netrc.read
        netrc_handle["api.github.com"] = username, token
        netrc_handle.save
      end
    end
  end
end
