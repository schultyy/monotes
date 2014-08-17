require 'spec_helper'
require 'monotes/authenticator'
require 'octokit'

describe Monotes::Authenticator do
  let(:api_client_mock) { double('Octokit::Client') }
  let(:username) { 'Jim' }
  let(:password) { 'passw' }
  let(:expected_token) { 'expected_token' }

  context 'without 2FA' do
    subject(:authenticator) { Monotes::Authenticator.new { |user, pass| api_client_mock } }

    before do
      allow(api_client_mock).to receive(:create_authorization).with(any_args).and_return(expected_token)
    end

    it 'authenticates without asking for 2-FA token' do
      actual_token = authenticator.get_oauth_token(username, password) { raise "2-FA Block was called" }
      expect(actual_token).to eq expected_token
    end
  end
  context 'with 2FA' do
    subject(:authenticator) { Monotes::Authenticator.new { |user, pass| api_client_mock } }

    before do
      params = { :scopes => ["user"], :note => Monotes::Authenticator::ACCESS_NOTE }
      allow(api_client_mock).to receive(:create_authorization).with(params).and_raise(Octokit::OneTimePasswordRequired)
    end

    it 'authenticates and asks for 2-FA token' do
      block_called = false
      authenticator.get_oauth_token(username, password) { block_called = true }
      expect(block_called).to be true
    end
  end
end
