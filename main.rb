require 'trello'
require 'active_support/inflector' #solely for `pluralize`
require 'sinatra'
require 'uri'
require 'slim'
require 'pp'
require 'kramdown'
require 'diffy'

use Rack::Session::Pool

# Let's ensure that we have a client just for us in the session before we
# process any URIs. It's cool tho, we'll save what you were requesting and send
# you back there after you've been authorized.
#
# The current version of the ruby-trello gem doesn't allow us to set the name
# of our application so we'll append it to the authorization URL, encoding it
# so that we can have things like spaces or slashes.
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

# Show me a list of the boards that I have access to
#
# This alone, is relatively useless from a user's perspective, but it's the
# groundwork for development of custom reports/workflow/etc.
get '/' do
  me =   session[:client].find(:member, 'me')
  erb :index, :locals => { :me => me, :boards => me.boards}
end

get '/card/:card_id' do |card_id|
  card = session[:client].find(:card, card_id)
  slim :card, :locals => { :card => card }
end

# Create an access token and store it in our client object.
get '/oauth/callback' do
  rt = session[:request_token]

  # this :oauth_verifier parameter was missing from nearly *every* example
  # that I found, but is completely necessary. You're welcome.
  at = rt.get_access_token :oauth_verifier => params[:oauth_verifier]
  session[:client].auth_policy.token = Trello::Authorization::OAuthCredential.new at.token, nil

  # Return from whence you came - http://www.youtube.com/watch?v=qBW2z0NZ5zA
  redirect URI::decode(params[:return])
end
