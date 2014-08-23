require 'thor'
require 'yaml'
require 'netrc'
require 'octokit'
require 'monotes/authenticator'
require 'monotes/issue_download'
require 'monotes/issue_repository'
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
        validate!("username", username)
        print "Password > "
        password = STDIN.noecho(&:gets).chomp
        validate!("password", password)
        puts "\n"
        authenticator = Monotes::Authenticator.new(Octokit::Client)
        begin
          oauth_token = authenticator.get_oauth_token(username, password) do
            print "Two-Factor token > "
            token = STDIN.gets.chomp
            validate!("Two-Factor token", token)
            token
          end
        rescue Octokit::Unauthorized => unauthorized
          puts "Unauthorized: #{unauthorized.message}"
          exit 77
        rescue Exception => e
          puts "FATAL: #{e.message}"
          exit 74
        else
          write_to_netrc(username, oauth_token.token)
        end
      end

      desc "download REPOSITORY", "Download issues for a repository"
      def download(repository)
        puts "Downloading issues for #{repository}..."
        downloader = Monotes::IssueDownload.new(Octokit)
        issues = downloader.download(repository)
        repository = Monotes::IssueRepository.build(repository: repository)
        repository.save(issues)
      end

      desc "show REPOSITORY", "Show downloaded issues"
      def show(repository_name)
        repository = Monotes::IssueRepository.build(repository: repository_name)
        issues = repository.load
        issues.map do |issue|
          STDOUT.puts "#{issue.number} - #{issue.title}"
        end
      end

      desc "create REPOSITORY TITLE", "Creates a new local issue"
      def create(repository_name, title)
        text = Monotes::BodyText.new(title)
        issue = text.create_issue
        repository = Monotes::IssueRepository.build(repository: repository_name)
        repository.append(issue)
      end

      desc "sync REPOSITORY", "Synchronizes local issues with GitHub"
      def sync(repository_name)
        repository = Monotes::IssueRepository.build(repository: repository_name)
        issues = repository.load
        already_synced = issues.reject { |i| i.unsynced }
        adapter = Octokit::Client.new(netrc: true)
        sync_list = Monotes::SyncList.new(list: issues, repo: repository_name, adapter: adapter)
        synced = sync_list.sync do |issue|
          puts "Synced issue #{issue.title}"
        end

        repository.save(already_synced.concat(synced))
      end

      private

      def validate!(name, param)
        if param.nil? || param.empty?
          puts "Fatal: #{name} cannot be empty"
          exit 74
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
