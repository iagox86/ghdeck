require 'json'

module GHDeck
	class Deck
		class Exception < ::GHDeck::Exception
		end

		# These are available for testing
		attr_accessor :shuffled, :reset

		# Shuffle the remaining cards in the deck
		def _shuffle!()
			if(@actually_shuffle)
				@deck.shuffle!()
			end

			# Testing
			@shuffled = true
		end

		def _reset!()
			# The order these are combined matters because of tests - they should
			# preserve the original order
			@deck = @discard + @deck

			# Be sure to empty the discard pile when we do this
			@discard = []
			_shuffle!()

			# Testing
			@reset = true
		end

		# Add a new card to the available deck. This also triggers a shuffle of the
		# available cards (but not a full reset of the deck, the discard pile stays
		# where it is)
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

		def initialize(deck:, actually_shuffle:true)
			# This is purely for debugging
			@actually_shuffle = actually_shuffle

			@deck = []
			@discard = []
			deck.each do |c|
				begin
					add_card(**c)
				rescue ArgumentError
					raise(Exception, "Each card definition needs to contain name, display, rolling, reshuffle, and remove")
				end
			end
			_shuffle!()

			# This will flip to `true` when a shuffle card is drawn (crit/miss)
			@reset_at_end_of_round = false

			# These are simply tracked for testing
			@shuffled = false
			@reset = false
		end

		# Draw a card
		def roll()
			# If we're out of cards, reset the deck
			if(@deck.length == 0)
				_reset!()
			end

			# If we're still out of cards, the deck was empty (oops!)
			if(@deck.length == 0)
				raise(Exception, "No cards in the deck!")
			end

			# Remove the first card from the deck...
			card = @deck.shift

			# ...and add it to the discard deck if it's not a discard card
			if(!card[:remove])
				@discard << card
			end

			# If the card triggers a reshuffle, queue that up
			if(card[:reshuffle])
				@reset_at_end_of_round = true
			end

			# Finally, return the card
			return card
		end

		# Reset the deck (eg, between dungeons)
		def reset_deck_to_clean()
			# Reset (puts everything back into the @deck, empties out the @discard
			# stack)
			_reset!()

			# Remove all the 'remove' cards from the deck
			@deck.select!() { |c| !c[:remove] }
		end

		def end_round()
			if(@reset_at_end_of_round)
				_reset!()
			end
		end

		def get()
			return @deck.clone(), @discard.clone()
		end
	end
end
