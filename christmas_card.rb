require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'base64'
require 'sanitize'
require 'zlib'
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'logger'

# Constants
MAX_NOTES = 1073741823


# Database config.
configure :development do
  DataMapper.setup(:default, {
    :adapter  => 'mysql',
    :host     => 'localhost',
    :username => 'christmas_card' ,
    :password => 'christmas_card',
    :database => 'christmas_card_development'})  

  DataMapper::Logger.new(STDOUT, :debug)
end

configure :production do

  DataMapper.setup(:default, ENV['CLEARDB_DATABASE_URL_A'])

  #For non PaaS deploys.
  #DataMapper.setup(:default, {
  #  :adapter  => 'mysql',
  #  :host     => 'localhost',
  #  :username => '' ,
  #  :password => '',
  #  :database => 'christmas_card_production'})  
end

# Model.
class Card
  include DataMapper::Resource
  property :id,         Serial
  property :to_thom,    Text, :required => true
  property :card_text,  Text, :required => true
  property :random_key, Text, :unique => true, :required => true

end

DataMapper.auto_upgrade!

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

post '/' do
  #Make sure hash doesn't exist
  hsh = rand(MAX_NOTES).to_s(36)
  while Card.count(:random_key => hash) > 0
    hsh = rand(MAX_NOTES).to_s(36)
  end

  card = Card.new
  card.attributes = {
                      :card_text => params[:card_text],
                      :random_key => hsh,
                    }

  card.save
  redirect to('/' + hsh)
  
end

get '/' do
  erb :index
end
 
get '/:key' do 
  #Need to fix this?
  #if Note.count(:random_key => params[:key]) <= 0
  #  erb :index
  
  #else
    @card = Card.first(:random_key => params[:key])
    erb :note
  #end
end

#Doesn't work. fix later

#get '/*.md' do
#  Note.first(:random_key => params[:splat]).note_text
#end
