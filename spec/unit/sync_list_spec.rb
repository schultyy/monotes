require 'spec_helper'
require 'fakefs'
require 'monotes/sync_list'

describe Monotes::SyncList do
  let(:issue) { double('Issue') }
  subject(:list) { Monotes::SyncList.new }

  before do
    allow(issue).to receive(:number).and_return(1)
    list.record('alice/example', issue)
  end

  it 'records a new issue' do
    expect(list.unsynced_count).to eq 1
  end
end
