require 'telegram/bot'
require 'net/http'

class YesBot
  attr_reader :current_quiz

  def initialize(bot)
    @bot = bot
    @current_quiz = set_current_quiz
  end

  def start(message)
    msg = "Hello, #{message.from.first_name}, I'm `but! yesBot`, your boring questionnaire."
    r = @bot.api.send_message(chat_id: message.chat.id, text: msg)
    puts r
  end

  def quiz(message)
    set_current_quiz
    question = @current_quiz['question']
    answers = [@current_quiz['correct_answer'], *@current_quiz['incorrect_answers']].shuffle
    kb = []

    answers.each do |ans|
      kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: ans, callback_data: ans)
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

    case message
    when Telegram::Bot::Types::CallbackQuery
      chat_id = message.from.id
    when Telegram::Bot::Types::Message
      chat_id = message.chat.id
    end
    @bot.api.send_message(chat_id: chat_id, text: question, reply_markup: markup)
  end

  def check_answer(message)
    correct_answer = @current_quiz['correct_answer']

    if message.data == correct_answer
      @bot.api.send_message(chat_id: message.from.id, text: 'Correct')
    else
      @bot.api.send_message(chat_id: message.from.id, text: 'Wrong')
      @bot.api.send_message(chat_id: message.from.id, text: "Correct answer is #{correct_answer}")
    end
  end

  def respond(message)
    case message.text
    when '/start'
      start(message)
      @bot.api.send_message(chat_id: message.chat.id, text: 'Enter /quiz to take a random quiz.')
    when '/quiz'
      quiz(message)
    else
      invalid(message)
    end
  end

  private

  def data(amount = 1)
    uri = URI("https://opentdb.com/api.php?amount=#{amount}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def invalid(message)
    msg = "O_O. Invalid command.\nAvailable commands are: \n\n/start\n/quiz"
    @bot.api.send_message(chat_id: message.chat.id, text: msg)
  end

  def set_current_quiz
    @current_quiz = data['results'][0]
  end
end
