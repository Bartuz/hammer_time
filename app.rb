require "sinatra"
require "sinatra/base"
require "sinatra/reloader"
require 'httparty'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/ban' do
    oath = params[:oath]
    HTTParty.post('https://gql.twitch.tv/gql',
        body: [
            {
                "operationName":"Chat_BanUserFromChatRoom",
                "variables":{
                    "input":{
                        "channelID":"487312485",
                        "bannedUserLogin":"b4dbw0y",
                        "expiresIn": nil
                    }
                },
                "extensions":{
                    "persistedQuery":{
                        "version":1,
                        "sha256Hash":"35471e9767ac2880baa53a8a59a6f8968f394cf6160bc94567d4a6750246828f"
                    }
                }
            }
        ].to_json,
        headers: {'Content-Type': 'text/plain;charset=UTF-8', 'Authorization': "OAuth #{oath}" }
    )
    'Zrobione'
  end

  get '/health' do
    'Breathing'
  end
end
