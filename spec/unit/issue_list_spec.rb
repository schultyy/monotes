require 'spec_helper'
require 'yaml'
require 'monotes/issue_list'

describe Monotes::IssueList do
  let(:issues) { build_list(:issue, 2) }
  let(:delegate) { double('fs delegate') }
  let(:repository) { 'franz/franz-seins' }

  context '#initialize' do
    it 'accepts delegate and repository' do
      expect { Monotes::IssueList.new(fs: delegate, repository: repository) }.to_not raise_error
    end

    it 'raises error when delegate not passed' do
      expect { Monotes::IssueList.new(repository: repository) }.to raise_error
    end

    it 'raises error when repository not passed' do
      expect { Monotes::IssueList.new(fs: delegate) }.to raise_error
    end
  end

  context '#save' do
    let(:list) { Monotes::IssueList.new(repository: repository, fs: delegate) }
    let(:issue) { issues.first }
    before do
      allow(delegate).to receive(:save)
    end

    it 'saves a single issue' do
      list.save(issue)
      expect(delegate).to have_received(:save).with(issue.to_yaml)
    end

    it 'saves a list of issues' do
      list.save(issues)
      expect(delegate).to have_received(:save).twice
    end
  end
end
