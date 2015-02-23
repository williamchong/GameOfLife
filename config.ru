require './app'
require './middlewares/chat_backend'
require './game'
Faye::WebSocket.load_adapter('thin')
use GameofLife::GameBackend

run GameofLife::App
