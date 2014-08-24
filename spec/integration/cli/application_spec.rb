require 'spec_helper'
require 'octokit'
require 'monotes/cli/application'

describe Monotes::CLI::Application do
  context '#pull' do
    let(:fs_mock) { double('fs-mock') }
    let(:repo_name)  { 'schultyy/pulp' }
    let(:issue_repository) { Monotes::IssueRepository.new(repository: repo_name, context: fs_mock) }
    subject(:application) { Monotes::CLI::Application.new }
    before do
      allow(Monotes::IssueRepository).to receive(:build).and_return(issue_repository)
      allow(fs_mock).to receive(:save)
    end

    it 'saves issues' do
      VCR.use_cassette('issues') do
        application.pull(repo_name)
        expect(fs_mock).to have_received(:save).with('schultyy', 'pulp', kind_of(Array))
      end
    end
  end
end
