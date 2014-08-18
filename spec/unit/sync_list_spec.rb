require 'spec_helper'
require 'fakefs'
require 'monotes/sync_list'

describe Monotes::SyncList do
  let(:issue) { double('Issue') }
  let(:fs_delegate) { double('fs_delegate') }
  subject(:list) { Monotes::SyncList.new(fs_delegate) }

  before do
    allow(issue).to receive(:number).and_return(1)
    allow(fs_delegate).to receive(:save)
    list.record('alice/example', issue)
  end

  it 'records a new issue' do
    expect(list.unsynced_count).to eq 1
  end

  it 'saves to file' do
    list.save
    expect(fs_delegate).to have_received(:save)
  end
end
