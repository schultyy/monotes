require 'spec_helper'
require 'monotes/sync_list'

describe Monotes::SyncList do
  let(:issue) { double('Issue') }
  let(:adapter) { double('OctoKit') }

  context '#initialize' do
    it 'accepts a list of issues' do
      expect { Monotes::SyncList.new(list: [issue], adapter: adapter) }.to_not raise_error
    end

    it 'raises error if no list was passed' do
      expect { Monotes::SyncList.new(adapter: adapter) }.to raise_error
    end

    it 'raises error if no adapter was passed' do
      expect { Monotes::SyncList.new(list: [issue] ) }.to raise_error
    end
  end

  context '#synchronize' do

  end
end
