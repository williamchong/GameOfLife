require './app'
require './middlewares/chat_backend'
require './game'
Faye::WebSocket.load_adapter('thin')
use ChatDemo::ChatBackend

run ChatDemo::App
