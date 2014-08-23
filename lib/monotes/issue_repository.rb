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

    def load
      @context.load(*@repository.split('/')).map do |issue_hash|
        Monotes::Models::Issue.new(issue_hash)
      end
    end

    def self.build(args)
      context = Monotes::IO::FSDelegate.new
      Monotes::IssueRepository.new(args.merge(:context => context))
    end
  end
end
