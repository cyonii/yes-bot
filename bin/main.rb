#!/usr/bin/env ruby
require 'json'
require 'telegram/bot'
require_relative '../lib/yesbot'

token = ENV['TELEGRAM_TOKEN']
client = Telegram::Bot::Client

client.run(token) do |bot|
  system('clear')
  puts 'yesbot is listening...'
  yesbot = YesBot.new(bot)

  bot.listen do |message|
    case message
    when Telegram::Bot::Types::CallbackQuery
      yesbot.check_answer(message)
    when Telegram::Bot::Types::Message
      yesbot.respond(message)
    end
  end
end
