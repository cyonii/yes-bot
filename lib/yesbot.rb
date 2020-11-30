require 'net/http'
require 'telegram/bot'

InlineButton = Telegram::Bot::Types::InlineKeyboardButton
Markup = Telegram::Bot::Types::InlineKeyboardMarkup

class YesBot
  def initialize(bot)
    @bot = bot
    set_current_quiz
  end

  def self.chat_id(message)
    case message
    when Telegram::Bot::Types::CallbackQuery
      message.from.id
    when Telegram::Bot::Types::Message
      message.chat.id
    end
  end

  def self.fetch_quiz(amount = 1)
    uri = URI("https://opentdb.com/api.php?amount=#{amount}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def respond(message)
    case message
    when Telegram::Bot::Types::CallbackQuery
      callback_query_handler(message)
    when Telegram::Bot::Types::Message
      message_handler(message)
    end
  end

  private

  def start(message)
    msg = "Hello, #{message.from.first_name}, I'm `but! yesBot`, your boring questionnaire."
    @bot.api.send_message(chat_id: YesBot.chat_id(message), text: msg)
  end

  def send_quiz(message)
    set_current_quiz
    question = @current_quiz['question']
    answers = [
      @current_quiz['correct_answer'],
      *@current_quiz['incorrect_answers']
    ].shuffle
    keyboard = answers.map { |ans| InlineButton.new(text: ans, callback_data: ans) }
    markup = Markup.new(inline_keyboard: keyboard)

    @bot.api.send_message(
      chat_id: YesBot.chat_id(message),
      text: question,
      reply_markup: markup,
      parse_mode: :HTML
    )
  end

  def callback_query_handler(message)
    correct_answer = @current_quiz['correct_answer']

    if message.data == correct_answer
      @bot.api.send_message(chat_id: YesBot.chat_id(message), text: 'Correct')
    else
      @bot.api.send_message(chat_id: YesBot.chat_id(message), text: 'Wrong')
    end
    @bot.api.send_message(
      chat_id: YesBot.chat_id(message),
      text: "*Correct answer is:* #{correct_answer}",
      parse_mode: :markdown
    )
  end

  def message_handler(message)
    case message.text
    when '/start'
      start(message)
      instruction = 'Enter /quiz to take a random quiz.'
      @bot.api.send_message(chat_id: YesBot.chat_id(message), text: instruction)
    when '/quiz'
      send_quiz(message)
    else
      send_invalid(message)
    end
  end

  def send_invalid(message)
    msg = "O_O. Invalid command.\nAvailable commands are: \n\n/start\n/quiz"
    @bot.api.send_message(chat_id: YesBot.chat_id(message), text: msg)
  end

  def set_current_quiz
    @current_quiz = YesBot.fetch_quiz['results'][0]
  end
end
