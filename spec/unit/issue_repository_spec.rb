require 'spec_helper'
require 'yaml'
require 'monotes/issue_repository'

describe Monotes::IssueRepository do
  let(:issues) { build_list(:issue, 2) }
  let(:context) { double('fs context') }
  let(:repository_name) { 'franz/franz-seins' }
  let(:issue) { issues.first }
  subject(:repository) { Monotes::IssueRepository.new(repository: repository_name, context: context) }

  context '#initialize' do
    it 'accepts context and repository' do
      expect { Monotes::IssueRepository.new(context: context, repository: repository_name) }.to_not raise_error
    end

    it 'raises error when context not passed' do
      expect { Monotes::IssueRepository.new(repository: repository_name) }.to raise_error
    end

    it 'raises error when repository not passed' do
      expect { Monotes::IssueRepository.new(context: context) }.to raise_error
    end
  end

  context '#save' do
    before do
      allow(context).to receive(:save)
    end

    it 'saves a single issue' do
      repository.save(issue)
      expect(context).to have_received(:save).with('franz', 'franz-seins', [issue.to_hash])
    end
  end

  context '#merge' do
    let(:upstream_issues) { build_list(:issue, 1, number: 5) }
    let(:existing_issues) { build_list(:issue, 2, number: 0, title: 'existing') }

    before do
      allow(context).to receive(:save)
      hashes = existing_issues.map{|i|i.to_hash}
      allow(context).to receive(:load).and_return(hashes)
    end

    context 'without conflicts' do
      before do
        repository.merge(upstream_issues)
      end

      it 'does not overwrite existing issues' do
        expect(context).to have_received(:save) do |user, repo, issues|
          expect(issues.length).to eq 3
        end
      end
    end

    context 'with conflicts' do
      before do
        repository.merge(upstream_issues)
      end

      context 'upstream is newer' do
        let(:upstream_issues) { build_list(:issue, 1, title: 'new', number: 5, updated_at: DateTime.parse("2014-08-24 10:30:14")) }
        let(:existing_issues) { build_list(:issue, 1, title: 'old', number: 5, updated_at: DateTime.parse("2014-08-24 08:30:14")) }

        it 'replaces local issue with upstream issue' do
          expect(context).to have_received(:save) do |user, repo, issues|
            expect(issues.first.fetch(:title)).to eq 'new'
          end
        end
      end

      context 'local is newer' do
        let(:upstream_issues) { build_list(:issue, 1, title: 'upstream', number: 5, updated_at: DateTime.parse("2014-08-24 08:30:14")) }
        let(:existing_issues) { build_list(:issue, 1, title: 'local', number: 5, updated_at: DateTime.parse("2014-08-24 10:30:14")) }

        it 'keeps local issue' do
          expect(context).to have_received(:save) do |user, repo, issues|
            expect(issues.first.fetch(:title)).to eq 'local'
          end
        end
      end

      context 'both are the same' do
        let(:upstream_issues) { build_list(:issue, 1, title: 'upstream', number: 5, updated_at: DateTime.parse("2014-08-24 10:30:14")) }
        let(:existing_issues) { build_list(:issue, 1, title: 'local', number: 5, updated_at: DateTime.parse("2014-08-24 10:30:14")) }

        it 'keeps the issue only once' do
          expect(context).to have_received(:save) do |user, repo, issues|
            ids = issues.map{|i| i.fetch(:number)}
            expect(ids.find_all{|i| i == 5 }.length).to eq 1
          end
        end
      end

      context 'upstream is marked as resolved' do
        let(:upstream_issues) { build_list(:issue, 1, title: 'upstream', number: 6, updated_at: DateTime.parse("2014-08-24 10:30:14")) }
        let(:existing_issues) { [build(:issue, title: 'local unresolved', number: 4, updated_at: DateTime.parse("2014-08-24 10:30:14")),
                                 build(:issue, title: 'local unresolved', number: 6, updated_at: DateTime.parse("2014-08-24 10:30:14"))] }

        it 'removes resolved issues locally' do
          expect(context).to have_received(:save) do |user, repo, issues|
            expect(issues.find{|i| i.fetch(:number) == 4}).to be nil
          end
        end
      end
    end
  end

  context '#has_issues?' do
    context 'with issues' do
      before do
        allow(context).to receive(:load).and_return(attributes_for_list(:issue, 2))
      end

      it 'returns true' do
        expect(repository.has_issues?).to be true
      end
    end
    context 'without issues' do
      before do
        allow(context).to receive(:load).and_return([])
      end

      it 'returns false' do
        expect(repository.has_issues?).to be false
      end
    end
  end

  context '#load' do
    before do
      allow(context).to receive(:load).and_return(attributes_for_list(:issue, 2))
    end

    it 'returns a list of issues' do
      expect(repository.load.length).to be > 0
    end

    context 'result set' do
      context 'element' do
        it 'is of type Issue' do
          issue = repository.load.first
          expect(issue.class).to eq Monotes::Models::Issue
        end
      end
    end
  end

  context '#append' do
    before do
      allow(context).to receive(:save)
      allow(context).to receive(:load).and_return(attributes_for_list(:issue, 1))
      repository.append(build(:issue))
    end

    it 'loads issues' do
      expect(context).to have_received(:load)
    end

    it 'saves with appended issue' do
      expect(context).to have_received(:save)
    end

    it 'raises error when issue is nil' do
      expect { repository.append(nil) }.to raise_error(ArgumentError)
    end
  end
end
