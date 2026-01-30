#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Handlers::HookedBrowsers do
  # .new returns Sinatra::Wrapper; use allocate to get the real class instance for unit testing
  let(:handler) { described_class.allocate }

  describe '#confirm_browser_user_agent' do
    it 'returns true when user_agent suffix matches a legacy UA string' do
      allow(BeEF::Core::Models::LegacyBrowserUserAgents).to receive(:user_agents).and_return(['IE 8.0'])

      # browser_type = user_agent.split(' ').last => '8.0'; 'IE 8.0'.include?('8.0') => true
      expect(handler.confirm_browser_user_agent('Mozilla/5.0 IE 8.0')).to be true
    end

    it 'returns true when first legacy UA matches' do
      allow(BeEF::Core::Models::LegacyBrowserUserAgents).to receive(:user_agents).and_return(['IE 8.0', 'Firefox/3.6'])

      expect(handler.confirm_browser_user_agent('Mozilla/5.0 IE 8.0')).to be true
    end

    it 'returns false when no legacy UA includes the browser type' do
      allow(BeEF::Core::Models::LegacyBrowserUserAgents).to receive(:user_agents).and_return([])

      expect(handler.confirm_browser_user_agent('Mozilla/5.0 Chrome/91.0')).to be false
    end

    it 'returns false when legacy list has entries but none match' do
      allow(BeEF::Core::Models::LegacyBrowserUserAgents).to receive(:user_agents).and_return(['IE 8.0'])

      expect(handler.confirm_browser_user_agent('Chrome/91.0')).to be false
    end
  end
end
