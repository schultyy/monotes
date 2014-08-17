require 'spec_helper'
require 'monotes/authenticator'
require 'octokit'

describe Monotes::Authenticator do
  let(:api_client_mock_class) { double('Octokit::Client') }
  let(:api_client_mock) { double('Octokit::Client instance') }
  let(:username) { 'Jim' }
  let(:password) { 'passw' }
  let(:expected_oauth_token) { 'expected_oauth_token' }

  context 'without 2FA' do
    subject(:authenticator) { Monotes::Authenticator.new(api_client_mock_class) }

    before do
      allow(api_client_mock_class).to receive(:new).with(any_args).and_return(api_client_mock)
      allow(api_client_mock).to receive(:create_authorization).with(any_args).and_return(expected_oauth_token)
    end

    it 'authenticates without asking for 2-FA token' do
      actual_token = authenticator.get_oauth_token(username, password) { raise "2-FA Block was called" }
      expect(actual_token).to eq expected_oauth_token
    end
  end
  context 'with 2FA' do
    let(:two_fa_token) { '2-factor token' }
    subject(:authenticator) { Monotes::Authenticator.new(api_client_mock_class) }

    before do
      params = { :scopes => ["user"], :note => Monotes::Authenticator::ACCESS_NOTE }
      params_with_2fa = params.merge(:headers => { "X-GitHub-OTP" => two_fa_token })
      allow(api_client_mock_class).to receive(:new).with(any_args).and_return(api_client_mock)
      allow(api_client_mock).to receive(:create_authorization).with(params).and_raise(Octokit::OneTimePasswordRequired)
      allow(api_client_mock).to receive(:create_authorization).with(params_with_2fa).and_return(expected_oauth_token)
    end

    it 'authenticates and asks for 2-FA token' do
      block_called = false
      authenticator.get_oauth_token(username, password) { block_called = true; two_fa_token }
      expect(block_called).to be true
    end

    it 'authenticates with 2-FA token' do
      actual_token = authenticator.get_oauth_token(username, password) { two_fa_token }
      expect(actual_token).to eq expected_oauth_token
    end
  end
end
