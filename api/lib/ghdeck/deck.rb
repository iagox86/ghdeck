require 'json'

module GHDeck
	class Deck
		class Exception < ::GHDeck::Exception
		end

		attr_accessor :shuffled

		def initialize(actually_shuffle:true)
			# This is purely for debugging
			@actually_shuffle = actually_shuffle
			@shuffled = false

			@shuffle_at_end_of_round = false
		end

		# Shuffle the deck in-place and return to index 0
		def _shuffle!()
			if(@actually_shuffle)
				@deck.shuffle!()
			end

			@index = 0

			# Testing
			@shuffled = true
		end

		# Add a new card to the deck, which also triggers a shuffle
		def add_card(name:, display:, rolling:, reshuffle:, remove:, **args)
			@deck << {
				name: name,
				display: display,
				rolling: rolling,
				reshuffle: reshuffle,
				remove: remove,
				**args,
			}

			_shuffle!()
		end

		def set_deck(deck)
			@deck = []
			deck.each do |c|
				begin
					add_card(**c)
				rescue ArgumentError
					raise(Exception, "Each card definition needs to contain name, display, rolling, reshuffle, and remove")
				end
			end
			_shuffle!()
		end

		# Draw a card
		def roll()
			if(@deck.length == 0)
				raise(Exception, "No cards in the deck!")
			end

			if(@index >= @deck.length)
				_shuffle!()
			end

			# TODO: Handle when the deck runs out of cards
			card = @deck[@index]

			# If the card is removed from the deck, do that; otherwise, go to the next
			# card
			if(card[:remove])
				@deck.delete_at(@index)
			else
				@index += 1
			end

			if(card[:reshuffle])
				@shuffle_at_end_of_round = true
			end

			return card
		end

		# Reset the deck (eg, between dungeons)
		def reset_deck()
			@deck.select!() { |c| !c[:remove] }
			@index = 0
		end

		def end_round()
			if(@shuffle_at_end_of_round)
				_shuffle!()
			end
		end

		def get()
			return @index, @deck.clone()
		end
	end
end
