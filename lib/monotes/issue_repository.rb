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

    def merge(upstream_issues)
      existing = load
      existing_ids = existing.map { |i| i.number }
      upstream_ids = upstream_issues.map { |i| i.number }
      resulting = existing.clone

      new = upstream_issues.reject { |i| existing_ids.include?(i) }
      # in place update of existing ones
      resulting = resulting.map do |issue|
        if upstream_ids.include?(issue.number)
          upstream = upstream_issues.find {|i| i.number }
          if issue.updated_at < upstream.updated_at
            upstream
          else
            issue
          end
        else
          issue
        end
      end

      save(resulting.concat(new).flatten.compact)
    end

    def self.build(args)
      context = Monotes::IO::FSDelegate.new
      Monotes::IssueRepository.new(args.merge(:context => context))
    end
  end
end
