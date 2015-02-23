require 'faye/websocket'
require 'thread'
require 'erb'
require 'json'
require 'faye/websocket'

module GameofLife
  class GameBackend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @clients = []
      @msg
      @game = Game.new(192,108)
      Thread.new do
        last_tick = Time.now
        while true do
          if((Time.now - last_tick)*1.0 >= 0.9)
            @game.tick
            last_tick = Time.now
            @msg=@game.to_json
            @clients.each {|client| client.send(@msg) }
          end
          sleep 0.1
        end
      end
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients << ws
          ws.send(@msg)
        end

        ws.on :message do |event|
          p [:message, event.data]
          data = JSON.parse(event.data)
          if data['type'] == 'new'
            if ((data['x'].is_a? Integer) && (data['y'].is_a? Integer) && (data['r'].is_a? Integer) && (data['g'].is_a? Integer) && (data['b'].is_a? Integer))
            @game.load(data['x'],data['y'],data['r'],data['g'],data['b'])
            @msg=@game.to_json
            @clients.each {|client| client.send(@msg) }
            end
          end
           
        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          @clients.delete(ws)
          ws = nil

        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    
  end
end
