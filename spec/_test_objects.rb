require 'telegram/bot'

TestUser = Telegram::Bot::Types::User.new(
  id: 100_442_642_833,
  is_bot: false,
  first_name: 'John',
  last_name: 'Doe',
  username: 'johndoe',
  language_code: 'en'
)

TestMessageEntity = Telegram::Bot::Types::MessageEntity.new(
  offset: 0,
  length: 6,
  type: 'bot_command'
)
TestChat = Telegram::Bot::Types::Chat.new(
  id: 452_422_223_678,
  first_name: 'John',
  last_name: 'Doe',
  username: 'johndoe',
  type: 'private',
  date: 1_605_786_503,
  text: '/start',
  entities: [TestMessageEntity]
)
TestMessage = Telegram::Bot::Types::Message.new(
  message_id: 323_424_424_553,
  from: TestUser,
  chat: TestChat
)

TestCallbackQuery = Telegram::Bot::Types::CallbackQuery.new(
  id: 546_789_821_376,
  from: TestUser,
  message: TestMessage
)
