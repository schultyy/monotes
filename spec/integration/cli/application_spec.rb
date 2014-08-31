require 'spec_helper'
require 'octokit'
require 'monotes/cli/application'

describe Monotes::CLI::Application do
  context '#pull' do
    let(:fs_mock) { double('fs-mock') }
    let(:repo_name)  { 'schultyy/pulp' }
    let(:issue_repository) { Monotes::IssueRepository.new(repository: repo_name, context: fs_mock) }
    let(:existing_issue) { build(:issue, :title => 'existing', updated_at: DateTime.parse("2014-08-24 10:30:14")) }
    subject(:application) { Monotes::CLI::Application.new }

    before do
      allow(Monotes::IssueRepository).to receive(:build).and_return(issue_repository)
      allow(fs_mock).to receive(:save)
      allow(fs_mock).to receive(:load).and_return([existing_issue.to_hash])
    end

    it 'saves issues' do
      VCR.use_cassette('issues') do
        application.pull(repo_name)
        expect(fs_mock).to have_received(:save).with('schultyy', 'pulp', kind_of(Array))
      end
    end

    it 'does not overwrite local issues' do
      VCR.use_cassette('issues') do
        application.pull(repo_name)
        expect(fs_mock).to have_received(:save) do |user, repo_name, issues|
          titles = issues.map {|i| i.fetch(:title) }
          expect(titles).to include('existing')
        end
      end
    end
  end
end
