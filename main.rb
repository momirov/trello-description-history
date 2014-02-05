require 'trello'
require 'active_support/inflector' #solely for `pluralize`
require 'sinatra'
require 'uri'

use Rack::Session::Pool

before do
  if session[:client].nil?
    session[:client] = Trello::Client.new( 
                                :consumer_key => ENV['CONSUMER_KEY'],
                                :consumer_secret => ENV['CONSUMER_SECRET'],
                                :return_url => url("/oauth/callback?return=#{URI::encode(request.url)}"),
                                :callback => lambda do |request_token| 
      session[:request_token] = request_token
      redirect to("#{request_token.authorize_url}&name=#{URI::encode(ENV['APP_NAME'])}&expiration=never"), 302
                                end)
  end
end

get '/' do
  me = session[:client].find(:member, 'me')
  erb :index, :locals => { :me => me, :boards => me.boards}
end

get '/oauth/callback' do
  rt = session[:request_token]
  at = rt.get_access_token :oauth_verifier => params[:oauth_verifier]
  session[:client].auth_policy.token = Trello::Authorization::OAuthCredential.new at.token, nil
  redirect URI::decode(params[:return])
end
