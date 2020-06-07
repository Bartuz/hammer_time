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
    day_param = params[:day]
    channel_id = params[:channel_id]
    channel_name = params[:channel_name]
    return 'Please specify ?oauth=xxx in URL params' if oauth.nil?
    return 'Please specify ?day=2020-04-20 in URL params' if day_param.nil?
    return 'Please specify ?channel_id=XXXX in URL params' if channel_id.nil?
    if channel_name.nil?
      return 'Please specify ?channel_name=XXXX in URL params'
    end

    date_filter = Date.parse(day_param)

    users_profiles_to_be_banned = users_profiles(oauth, channel_name).filter { |profile| profile[:created_at] == date_filter }
    users_to_be_banned = users_profiles_to_be_banned.map { |profile| profile[:user] }
    ban_users(oauth: oauth, users: users_to_be_banned, channel_id: channel_id)
    "banned: #{users_to_be_banned}"
  end

  get '/health' do
    'Breathing'
  end

  def user_names(channel)
    @response_user_names ||= JSON.parse(HTTParty.get("https://tmi.twitch.tv/group/user/#{channel}/chatters").body)
    @response_user_names['chatters'].map { |_group, members| members }.flatten
  end

  def users_profiles(oauth, channel_name)
    headers = { 'Accept': 'application/vnd.twitchtv.v5+json', 'Authorization': "OAuth #{oauth}" }
    Array(user_names(channel_name)).each_slice(99).map do |user_ids|
      response = JSON.parse(HTTParty.get("https://api.twitch.tv/kraken/users?login=#{user_ids.join(',')}", headers: headers).body)
      response['users'].map { |profile| { user: profile['name'], created_at: Date.parse(profile['created_at']) } }.flatten
    end.flatten
  end

  def ban_users(oauth:, users:, channel_id:)
    headers = { 'Content-Type': 'text/plain;charset=UTF-8', 'Authorization': "OAuth #{oauth}" }
    users.each_slice(10) do |users_slice|
      slice_payload = users_slice.map do |user|
        {
          "operationName": 'Chat_BanUserFromChatRoom',
          "variables": {
            "input": {
              "channelID": channel_id,
              "bannedUserLogin": user,
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
      end
      body = slice_payload.to_json
      puts(HTTParty.post('https://gql.twitch.tv/gql', body: body, headers: headers))
    end
  end
end
