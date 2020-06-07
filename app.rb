# frozen_string_literal: true

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'httparty'
require 'pry'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/ban' do
    oauth = params[:oauth]
    return 'Please specify ?oauth=xxx in URL params' if oauth.empty?

    ban_single_user(oauth)
    users_profiles(oauth).to_json
  end

  get '/health' do
    'Breathing'
  end

  def user_names(channel = 'kath9000')
    @response_user_names ||= JSON.parse(HTTParty.get("https://tmi.twitch.tv/group/user/#{channel}/chatters").body)
    @response_user_names['chatters'].map { |_group, members| members }.flatten
  end

  def users_profiles(oauth)
    users_ids = Array(user_names).join(',')
    headers = { 'Accept': 'application/vnd.twitchtv.v5+json', 'Authorization': "OAuth #{oauth}"}
    @response_users_profiles ||= JSON.parse(HTTParty.get("https://api.twitch.tv/kraken/users?login=#{users_ids}", headers: headers).body)
    @response_users_profiles['users'].map { |profile| { user: profile['name'], created_at: Date.parse(profile['created_at']) } }.flatten
  end

  def ban_single_user(oauth)
    body = [
      {
        "operationName": 'Chat_BanUserFromChatRoom',
        "variables": {
          "input": {
            "channelID": '487312485',
            "bannedUserLogin": 'b4dbw0y',
            "expiresIn": nil
          }
        },
        "extensions": {
          "persistedQuery": {
            "version": 1,
            "sha256Hash": '35471e9767ac2880baa53a8a59a6f8968f394cf6160bc94567d4a6750246828f'
          }
        }
      }
    ].to_json
    headers = { 'Content-Type': 'text/plain;charset=UTF-8', 'Authorization': "OAuth #{oauth}" }
    HTTParty.post('https://gql.twitch.tv/gql', body: body, headers: headers)
  end
end
