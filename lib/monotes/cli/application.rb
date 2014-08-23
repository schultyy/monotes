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
        STDOUT.puts "\n"
        authenticator = Monotes::Authenticator.new(Octokit::Client)
        begin
          oauth_token = authenticator.get_oauth_token(username, password) do
            print "Two-Factor token > "
            token = STDIN.gets.chomp
            validate!("Two-Factor token", token)
            token
          end
        rescue Octokit::Unauthorized => unauthorized
          STDERR.puts "Unauthorized: #{unauthorized.message}"
          exit 77
        rescue Exception => e
          fatal!(e)

        else
          write_to_netrc(username, oauth_token.token)
        end
      end

      desc "download REPOSITORY", "Download issues for a repository"
      def download(repository)
        STDOUT.puts "Downloading issues for #{repository}..."
        downloader = Monotes::IssueDownload.new(Octokit)
        begin
          issues = downloader.download(repository)
        rescue Exception => exc
          fatal!(exc)
        end
        repository = Monotes::IssueRepository.build(repository: repository)
        repository.save(issues)
      end

      desc "show REPOSITORY", "Show downloaded issues"
      def show(repository_name)
        repository = Monotes::IssueRepository.build(repository: repository_name)
        issues = repository.load
        issues.map do |issue|
          if issue.unsynced?
            STDOUT.puts "(new) - #{issue.title}"
          else
            STDOUT.puts "#{issue.number} - #{issue.title}"
          end
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
        already_synced = issues.reject { |i| i.unsynced? }
        adapter = Octokit::Client.new(netrc: true)
        begin
          sync_list = Monotes::SyncList.new(list: issues, repo: repository_name, adapter: adapter)
          synced = sync_list.sync do |issue|
            STDOUT.puts "Synced issue #{issue.title}"
          end
        rescue Exception => exc
          fatal!(exc)
        end
        repository.save(already_synced.concat(synced))
      end

      private

      def fatal!(exc)
        STDERR.puts "FATAL: #{exc.message}"
        exit 74
      end

      def validate!(name, param)
        if param.nil? || param.empty?
          STDERR.puts "Fatal: #{name} cannot be empty"
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
