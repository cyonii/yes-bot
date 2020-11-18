require 'telegram/bot'
require_relative '../lib/yesbot'

describe YesBot do
  let(:client) { Telegram::Bot::Client }
  let(:yesbot) { YesBot.new(client) }

  describe '#initialize' do
    it 'creates a new YesBot object' do
      expect(yesbot.class).to be(YesBot)
      expect(yesbot.current_quiz).to be_a(Hash)
    end

    context 'when argument is not passed to #new' do
      it 'raises ArgumentError' do
        expect { YesBot.new }.to raise_error(ArgumentError)
      end
    end
  end
end
