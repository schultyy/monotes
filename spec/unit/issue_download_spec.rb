require 'spec_helper'
require 'monotes/issue_download'

describe Monotes::IssueDownload do
  let(:octo_mock) { double('Octokit') }
  let(:issue_list) { [attributes_for(:issue)] }
  let(:repository) { 'franz/franz-repo' }
  subject(:downloader) { Monotes::IssueDownload.new(octo_mock) }

  context '#download' do
    before do
      allow(octo_mock).to receive(:list_issues).and_return(issue_list)
    end
    it 'returns a list of issues' do
      expect(downloader.download(repository).length).to be > 0
    end

    it 'raises error when repository is nil' do
      expect { downloader.download(nil) }.to raise_error(ArgumentError)
    end
  end
end
