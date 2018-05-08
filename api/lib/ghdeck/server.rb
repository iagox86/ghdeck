require 'json'
require 'sinatra'
require 'sinatra/base'
require 'rack/robustness'

require 'ghdeck'
require 'ghdeck/cards'
require 'ghdeck/deck'
require 'ghdeck/decks'
require 'ghdeck/logger'

module GHDeck
	CARDS = Cards.new(filename: '~/.ghdeck/available_cards')
	DECKS = Decks.new(filename: '~/.ghdeck/decks', cards: CARDS)

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

		# Cards api
    get '/api/cards' do
			return CARDS.get()
    end

		post '/api/cards' do
			CARDS.add(**@body)
		end

		delete '/api/cards/:id' do |id|
			CARDS.delete(id)
		end

		# Decks API
		get '/api/decks' do
			return DECKS.get()
		end

		post '/api/decks' do
			DECKS.add(**@body)
		end

		delete '/api/decks/:id' do |id|
			DECKS.delete(id)
		end

		# Decks cards API
		get '/api/decks/:id/cards' do |id|
			return DECKS.get_cards_for(id)
		end

		post '/api/decks/:id/cards' do |id|
			DECKS.add_card(
				id: id,
				card_id: @body[:card_id],
			)
		end

		delete '/api/decks/:id/cards/:card_id' do |id, card_id|
			DECKS.delete_card(
				id: id,
				card_id: card_id
			)
		end
  end
end
