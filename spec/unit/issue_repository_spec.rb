require 'spec_helper'
require 'yaml'
require 'monotes/issue_repository'

describe Monotes::IssueRepository do
  let(:issues) { build_list(:issue, 2) }
  let(:context) { double('fs context') }
  let(:repository_name) { 'franz/franz-seins' }

  context '#initialize' do
    it 'accepts context and repository' do
      expect { Monotes::IssueRepository.new(context: context, repository: repository_name) }.to_not raise_error
    end

    it 'raises error when context not passed' do
      expect { Monotes::IssueRepository.new(repository: repository_name) }.to raise_error
    end

    it 'raises error when repository not passed' do
      expect { Monotes::IssueRepository.new(context: context) }.to raise_error
    end
  end

  context '#save' do
    let(:repository) { Monotes::IssueRepository.new(repository: repository_name, context: context) }
    let(:issue) { issues.first }
    before do
      allow(context).to receive(:save)
    end

    it 'saves a single issue' do
      repository.save(issue)
      expect(context).to have_received(:save).with('franz', 'franz-seins', [issue.to_hash])
    end
  end
end
