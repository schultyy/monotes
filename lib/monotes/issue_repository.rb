require 'yaml'
require 'monotes/IO/fs_delegate'

module Monotes
  class IssueRepository

    def initialize(args)
      @context = args.fetch(:context)
      @repository = args.fetch(:repository)
    end

    def save(args)
      issues = Array(args).map do |issue|
        issue.to_hash
      end
      @context.save(*@repository.split('/'), issues)
    end

    def append(new_issue)
      raise ArgumentError, 'issue must not be nil' if new_issue.nil?
      issues = load
      issues << new_issue
      save(issues)
    end

    def load
      @context.load(*@repository.split('/')).map do |issue_hash|
        Monotes::Models::Issue.new(issue_hash)
      end
    end

    def has_issues?
      @context.load.length > 0
    end

    def merge(new_issues)
      resulting = self.load
      ids = resulting.map {|i| i.number }
      new_issues.each do |issue|
        unless ids.include?(issue.number)
          resulting << issue
        end
      end
      save(resulting)
    end

    def self.build(args)
      context = Monotes::IO::FSDelegate.new
      Monotes::IssueRepository.new(args.merge(:context => context))
    end
  end
end
