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
        Monotes::SyncList.new(list: build_list(:issue, 1),
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
    let(:synced_issues) { build_list(:issue, 1, number: 45, title: 'baz', body:'yadda yadda') }
    let(:issue_result) { attributes_for(:issue, number: 1, id: 1) }

    before(:each) do
      allow(adapter).to receive(:create_issue) { issue_result }
    end

    context 'with unsynced issues' do
      subject(:sync_list) { Monotes::SyncList.new(list: unsynced_issues, adapter: adapter, repo: repo_name) }

      it 'calls adapter to create issue' do
        sync_list.sync
        expect(adapter).to have_received(:create_issue).with(repo_name, 'foo', 'bar')
      end

      it 'calls block for each issue' do
        block_called = false
        sync_list.sync { |issue| block_called = true }
        expect(block_called).to be true
      end

      it 'calls block with result from adapter call' do
        block_result = nil
        sync_list.sync { |issue| block_result = issue }
        expect(block_result).to eq issue_result
      end

      context 'after sync' do
        context 'issue' do
          it 'has number' do
            result = sync_list.sync.first
            expect(result.unsynced?).to be false
          end
          it 'has id' do
            result = sync_list.sync.first
            expect(result.id).to_not eq 0
          end
        end
      end
    end

    context 'with synced and unsynced issues' do
      subject(:sync_list) { Monotes::SyncList.new(list: unsynced_issues.concat(synced_issues), adapter: adapter, repo: repo_name) }

      it 'calls adapter only for unsynced issue' do
        sync_list.sync
        expect(adapter).to have_received(:create_issue).with(repo_name, 'foo', 'bar').once
      end
    end
  end
end
