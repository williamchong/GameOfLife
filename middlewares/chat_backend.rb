require 'faye/websocket'
require 'thread'
require 'json'
require 'erb'

require 'faye/websocket'

module ChatDemo
  class ChatBackend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @clients = []
      @game = Game.new(192,108)
      Thread.new do
        last_tick = Time.now
        while true do
          if(Time.now - last_tick >= 0.5)
            @game.tick
            last_tick = Time.now
          end
          @clients.each {|client| client.send(@game.to_s) }
          sleep 0.2
        end
      end
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients << ws
          ws.send(@game.to_s)
        end

        ws.on :message do |event|
          p [:message, event.data]
          data = JSON.parse(event.data)
          if data['type'] == 'new'
            if ((data['x'].is_a? Integer) && (data['y'].is_a? Integer) && (data['r'].is_a? Integer) && (data['g'].is_a? Integer) && (data['b'].is_a? Integer))
            @game.load(data['x'],data['y'],data['r'],data['g'],data['b'])
            @clients.each {|client| client.send(@game.to_s) }
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

    private
    def sanitize(message)
      json = JSON.parse(message)
      json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
      JSON.generate(json)
    end
  end
end
