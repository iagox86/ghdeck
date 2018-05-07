require 'json'
require 'sinatra'
require 'sinatra/base'
require 'rack/robustness'

require 'ghdeck'
require 'ghdeck/cards'
require 'ghdeck/deck'
require 'ghdeck/logger'

module GHDeck
  class Server < Sinatra::Base
    def initialize(*args)
      super(*args)

      @logger = Logger.instance()
    end

		# TODO: This doesn't actually do anything yet
    configure do
      if(defined?(PARAMS))
        set :port, PARAMS[:port]
        set :bind, PARAMS[:host]
      end
     end

    # Handle errors cleanly
    use Rack::Robustness do |g|
      # Always use application/json
      g.content_type 'application/json'

      # If it's bad JSON, it's a user error
      g.on(JSON::ParserError) { 400 }

      # If it's our own exception, it's also a user error
      g.on(GHDeck::Exception) { 400 }

      # (All other exceptions trigger a 500)

      # Create a JSON response with the error text
      g.body do |ex|
        {
          'error' => ex.message,
          #'backtrace' => ex.backtrace,
        }.to_json
      end
    end

    not_found do
      return 404, { 'error': "Unknown route" }.to_json
    end

    # Parse the JSON body - if the JSON is bad, the Rack::Robustness middleware will
    # handle the exception cleanly
    before do
      request.body.rewind
      body = request.body.read
      @body = {}
      if(body.length > 0)
        @payload = JSON.parse(body, :symbolize_names => true)
      end
    end

    get '/api/cards' do
    end

		post '/api/card/add' do
		end

		delete '/api/card/:id' do |id|
		end

		post '/api/decks' do
		end

		put '/api/deck/:id' do |id|
		end

		post '/api/deck' do
      id = SecureRandom.uuid()
			puts(id)
		end

		delete '/api/deck/:id' do |id|
		end

		put '/api/deck/:id' do
		end

		get '/api/deck/:id/roll' do |id|
		end
  end
end
