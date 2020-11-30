#!/usr/bin/env ruby
require 'json'
require 'telegram/bot'
require_relative '../lib/yesbot'

token = ENV['TELEGRAM_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  system('clear')
  puts 'yesbot is listening...'
  yesbot = YesBot.new(bot)

  bot.listen { |message| yesbot.respond(message) }
end
