require 'spec_helper'
require 'yaml'
require 'monotes/issue_repository'

describe Monotes::IssueRepository do
  let(:issues) { build_list(:issue, 2) }
  let(:delegate) { double('fs delegate') }
  let(:repository_name) { 'franz/franz-seins' }

  context '#initialize' do
    it 'accepts delegate and repository' do
      expect { Monotes::IssueRepository.new(fs: delegate, repository: repository_name) }.to_not raise_error
    end

    it 'raises error when delegate not passed' do
      expect { Monotes::IssueRepository.new(repository: repository_name) }.to raise_error
    end

    it 'raises error when repository not passed' do
      expect { Monotes::IssueRepository.new(fs: delegate) }.to raise_error
    end
  end

  context '#save' do
    let(:repository) { Monotes::IssueRepository.new(repository: repository_name, fs: delegate) }
    let(:issue) { issues.first }
    before do
      allow(delegate).to receive(:save)
    end

    it 'saves a single issue' do
      repository.save(issue)
      expect(delegate).to have_received(:save).with(issue.to_yaml)
    end

    it 'saves a list of issues' do
      repository.save(issues)
      expect(delegate).to have_received(:save).twice
    end
  end
end
