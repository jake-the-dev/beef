#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Example: unit specs for AutorunEngine::Engine using mocks instead of a real server/DB.
#

require 'spec_helper'

RSpec.describe BeEF::Core::AutorunEngine::Engine do
  let(:engine) { described_class.instance }
  let(:config) { BeEF::Core::Configuration.instance }

  before do
    allow(engine).to receive(:print_debug)
    allow(engine).to receive(:print_info)
    allow(engine).to receive(:print_more)
    allow(engine).to receive(:print_error)
  end

  # Fake rule object (could be a double or a persisted Rule with minimal attributes)
  def rule_with(browser: 'ALL', browser_version: 'ALL', os: 'ALL', os_version: 'ALL')
    double(
      'Rule',
      id: 1,
      browser: browser,
      browser_version: browser_version,
      os: os,
      os_version: os_version
    )
  end

  describe '#zombie_matches_rule?' do
    it 'returns false when rule is nil' do
      expect(engine.zombie_matches_rule?('FF', '41', 'Windows', '7', nil)).to be false
    end

    it 'returns true when rule is ALL for browser and OS' do
      rule = rule_with(browser: 'ALL', browser_version: 'ALL', os: 'ALL', os_version: 'ALL')
      allow(engine).to receive(:zombie_browser_matches_rule?).with('FF', '41', rule).and_return(true)
      allow(engine).to receive(:zombie_os_matches_rule?).with('Windows', '7', rule).and_return(true)
      expect(engine.zombie_matches_rule?('FF', '41', 'Windows', '7', rule)).to be true
    end

    it 'returns false when browser does not match' do
      rule = rule_with(browser: 'FF', browser_version: '>= 41', os: 'ALL', os_version: 'ALL')
      allow(engine).to receive(:zombie_browser_matches_rule?).with('FF', '41', rule).and_return(false)
      expect(engine.zombie_matches_rule?('FF', '41', 'Windows', '7', rule)).to be false
    end

    it 'returns false when OS does not match' do
      rule = rule_with(browser: 'ALL', browser_version: 'ALL', os: 'Windows', os_version: '7')
      allow(engine).to receive(:zombie_browser_matches_rule?).with('FF', '41', rule).and_return(true)
      allow(engine).to receive(:zombie_os_matches_rule?).with('Windows', '7', rule).and_return(false)
      expect(engine.zombie_matches_rule?('FF', '41', 'Windows', '7', rule)).to be false
    end
  end

  describe '#zombie_os_matches_rule?' do
    it 'returns false when rule is nil' do
      expect(engine.zombie_os_matches_rule?('Windows', '7', nil)).to be false
    end

    it 'returns true when rule os is ALL' do
      rule = double('Rule', os: 'ALL', os_version: 'ALL')
      expect(engine.zombie_os_matches_rule?('Windows', '7', rule)).to be true
    end

    it 'returns false when hook os does not match rule os' do
      rule = double('Rule', os: 'Linux', os_version: 'ALL')
      expect(engine.zombie_os_matches_rule?('Windows', '7', rule)).to be false
    end

    it 'returns true when rule os matches and os_version is ALL' do
      rule = double('Rule', os: 'Windows', os_version: 'ALL')
      expect(engine.zombie_os_matches_rule?('Windows', '7', rule)).to be true
    end
  end

  describe '#zombie_browser_matches_rule?' do
    it 'returns false when rule is nil' do
      expect(engine.zombie_browser_matches_rule?('FF', '41', nil)).to be false
    end

    it 'returns true when rule browser is ALL and version is ALL' do
      rule = double('Rule', browser: 'ALL', browser_version: 'ALL')
      expect(engine.zombie_browser_matches_rule?('FF', '41', rule)).to be true
    end

    it 'returns true when rule browser matches and version is ALL' do
      rule = double('Rule', browser: 'FF', browser_version: 'ALL')
      expect(engine.zombie_browser_matches_rule?('FF', '41', rule)).to be true
    end

    it 'returns false when rule browser does not match' do
      rule = double('Rule', browser: 'IE', browser_version: 'ALL')
      expect(engine.zombie_browser_matches_rule?('FF', '41', rule)).to be false
    end
  end

  describe '#find_matching_rules_for_zombie' do
    it 'returns nil when no rules exist' do
      allow(BeEF::Core::Models::Rule).to receive(:all).and_return([])
      expect(engine.find_matching_rules_for_zombie('FF', '41', 'Windows', '7')).to be_nil
    end

    it 'returns matching rule ids when rules match zombie' do
      rule1 = double('Rule', id: 1, name: 'Rule1', browser: 'ALL', browser_version: 'ALL', os: 'ALL', os_version: 'ALL')
      rule2 = double('Rule', id: 2, name: 'Rule2', browser: 'IE', browser_version: 'ALL', os: 'ALL', os_version: 'ALL')
      allow(BeEF::Core::Models::Rule).to receive(:all).and_return([rule1, rule2])
      allow(engine).to receive(:zombie_matches_rule?).with('FF', '41', 'Windows', '7', rule1).and_return(true)
      allow(engine).to receive(:zombie_matches_rule?).with('FF', '41', 'Windows', '7', rule2).and_return(false)
      expect(engine.find_matching_rules_for_zombie('FF', '41', 'Windows', '7')).to eq([1])
    end
  end
end
