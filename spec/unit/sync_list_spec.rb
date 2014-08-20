require 'spec_helper'
require 'monotes/models/issue'
require 'monotes/sync_list'

describe Monotes::SyncList do
  let(:issue) { Monotes::Models::Issue.new }
  let(:adapter) { double('OctoKit') }
  let(:repo_name) { 'alice/example' }

  context '#initialize' do
    it 'accepts a list of issues' do
      expect do
        Monotes::SyncList.new(list: [issue],
                              adapter: adapter,
                              repo: repo_name)
      end.to_not raise_error
    end

    it 'raises error if no list was passed' do
      expect { Monotes::SyncList.new(adapter: adapter, repo: repo_name) }.to raise_error
    end

    it 'raises error if no adapter was passed' do
      expect { Monotes::SyncList.new(list: [issue], repo: repo_name) }.to raise_error
    end

    it 'raises error if no repository name was passed' do
      expect { Monotes::SyncList.new(list: [issue], adapter: adapter) }.to raise_error
    end
  end

  context '#sync' do
    let(:unsynced_issues) { build_list(:issue, 1, number: 0, title: 'foo', body:'bar') }
    subject(:sync_list) { Monotes::SyncList.new(list: unsynced_issues, adapter: adapter, repo: repo_name) }

    before do
      allow(adapter).to receive(:create_issue)
    end

    it 'calls adapter to save issue' do
      sync_list.sync
      expect(adapter).to have_received(:create_issue).with(repo_name, 'foo', 'bar')
    end
  end
end
