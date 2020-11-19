require 'telegram/bot'
require_relative '../lib/yesbot'
require_relative '_test_objects'

describe YesBot do
  let(:client) { Telegram::Bot::Client.new('fake_7ab-3edfd-31dsa2') }
  let(:yesbot) { YesBot.new(client) }

  describe '#initialize' do
    it 'creates a new YesBot object' do
      expect(yesbot).to be_a(YesBot)
    end

    context 'when argument is not passed to #new' do
      it 'raises ArgumentError' do
        expect { YesBot.new }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.chat_id' do
    context 'when message is a Telegram::Bot::Types::Message' do
      it 'returns the chat id of message' do
        expect(YesBot.chat_id(TestMessage)).to eql(452_422_223_678)
      end
    end

    context 'when message is a Telegram::Bot::Types::CallbackQuery' do
      it 'returns the chat id of message' do
        expect(YesBot.chat_id(TestCallbackQuery)).to eql(100_442_642_833)
      end
    end
  end

  describe '#respond' do
    context 'when message is a Telegram::Bot::Types::CallbackQuery' do
      it 'attempts to connect to Telegram API' do
        expect { yesbot.respond(TestCallbackQuery) }.to raise_error(
          Telegram::Bot::Exceptions::ResponseError
        )
      end
    end

    context 'when message is a Telegram::Bot::Types::Message' do
      it 'attempts to connect to Telegram API' do
        expect { yesbot.respond(TestMessage) }.to raise_error(
          Telegram::Bot::Exceptions::ResponseError
        )
      end
    end
  end

  describe '.fetch_quiz' do
    it 'fetches quiz API from opentdb.com API' do
      expect(YesBot.fetch_quiz).to be_a(Hash)
    end
  end
end
