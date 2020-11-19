require 'htmlentities'
require 'net/http'
require 'telegram/bot'

HTML = HTMLEntities.new
InlineButton = Telegram::Bot::Types::InlineKeyboardButton
Markup = Telegram::Bot::Types::InlineKeyboardMarkup

class YesBot
  def initialize(bot)
    @bot = bot
    set_current_quiz
  end

  def start(message)
    msg = "Hello, #{message.from.first_name}, I'm `but! yesBot`, your boring questionnaire."
    @bot.api.send_message(chat_id: chat_id(message), text: msg)
  end

  def send_quiz(message)
    set_current_quiz
    question = HTML.decode(@current_quiz['question'])
    answers = [
      @current_quiz['correct_answer'],
      *@current_quiz['incorrect_answers']
    ].shuffle.map { |ans| HTML.decode(ans) }
    kb = []

    answers.each { |ans| kb << InlineButton.new(text: ans, callback_data: ans) }
    markup = Markup.new(inline_keyboard: kb)

    @bot.api.send_message(chat_id: chat_id(message), text: question, reply_markup: markup)
  end

  def chat_id(message)
    case message
    when Telegram::Bot::Types::CallbackQuery
      message.from.id
    when Telegram::Bot::Types::Message
      message.chat.id
    end
  end

  def callback_query_handler(message)
    correct_answer = HTML.decode(@current_quiz['correct_answer'])

    if message.data == correct_answer
      @bot.api.send_message(chat_id: chat_id(message), text: 'Correct')
    else
      @bot.api.send_message(chat_id: chat_id(message), text: 'Wrong')
      @bot.api.send_message(chat_id: chat_id(message), text: "Correct answer is #{correct_answer}")
    end
  end

  def message_handler(message)
    case message.text
    when '/start'
      start(message)
      @bot.api.send_message(chat_id: chat_id(message), text: 'Enter /quiz to take a random quiz.')
    when '/quiz'
      send_quiz(message)
    else
      send_invalid(message)
    end
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

  def fetch_quiz(amount = 1)
    uri = URI("https://opentdb.com/api.php?amount=#{amount}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def send_invalid(message)
    msg = "O_O. Invalid command.\nAvailable commands are: \n\n/start\n/quiz"
    @bot.api.send_message(chat_id: chat_id(message), text: msg)
  end

  def set_current_quiz
    @current_quiz = fetch_quiz['results'][0]
  end
end
