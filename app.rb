require 'sinatra/base'

module GameofLife
  class App < Sinatra::Base
    get "/" do
      erb :"index.html"
    end

    get "/assets/js/application.js" do
      content_type :js
      erb :"application.js"
    end
  end
end
