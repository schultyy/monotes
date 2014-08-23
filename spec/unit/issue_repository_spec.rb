require 'spec_helper'
require 'yaml'
require 'monotes/issue_repository'

describe Monotes::IssueRepository do
  let(:issues) { build_list(:issue, 2) }
  let(:context) { double('fs context') }
  let(:repository_name) { 'franz/franz-seins' }
  let(:issue) { issues.first }
  subject(:repository) { Monotes::IssueRepository.new(repository: repository_name, context: context) }

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
    before do
      allow(context).to receive(:save)
    end

    it 'saves a single issue' do
      repository.save(issue)
      expect(context).to have_received(:save).with('franz', 'franz-seins', [issue.to_hash])
    end
  end

  context '#load' do
    before do
      allow(context).to receive(:load).and_return(attributes_for_list(:issue, 2))
    end

    it 'returns a list of issues' do
      expect(repository.load.length).to be > 0
    end

    context 'result set' do
      context 'element' do
        it 'is of type Issue' do
          issue = repository.load.first
          expect(issue.class).to eq Monotes::Models::Issue
        end
      end
    end
  end
end
