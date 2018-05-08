require 'json'
require 'securerandom'

module GHDeck
	class Decks
		public
		class Exception < ::GHDeck::Exception
		end

		public
		def initialize(filename:, cards:)
			@filename = File.expand_path(filename)

			File.open(filename, 'r') do |f|
				@decks = JSON.parse(f.read())
			end
		end

		private
		def _save()
			@file.open(filename, 'w') do |f|
				f.write(@decks.to_json())
			end
		end

		public
		def add(name:)
			id = SecureRandom.uuid()
			@decks[id] = {
				name: name,
				cards: [], # TODO: Make this a default deck
			}
		end

		public
		def delete(id:)
			@decks.delete(id)
			_save()
		end

		public
		def add_card(id:, card_id:)
			@decks[id][:cards] << card_id
			_save()
		end

		public
		def delete_card(id:, card_id:)
			i = @decks[:id][:cards].index(id)
			if(i)
				@decks[:id][:cards].delete_at(i)
			end
			_save()
		end

		public
		def get()
			return @decks.clone
		end

		public
		def get_cards_for(id:)
			return @decks[id][:cards].map { |c| @cards.get_card(id: c) }
		end
	end
end
