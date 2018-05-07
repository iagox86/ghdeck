require 'test_helper'

require 'ghdeck/deck'

module GHDeck
	class DeckTest < ::Test::Unit::TestCase
		def setup()
			@test_cards = {
				normal1:    { name: "normal1",    display: "n1",  rolling: false, reshuffle: false, remove: false },
				normal2:    { name: "normal2",    display: "n2",  rolling: false, reshuffle: false, remove: false },
				normal3:    { name: "normal3",    display: "n3",  rolling: false, reshuffle: false, remove: false },

				rolling1:   { name: "rolling1",   display: "r1",  rolling: true,  reshuffle: false, remove: false },
				rolling2:   { name: "rolling2",   display: "r2",  rolling: true,  reshuffle: false, remove: false },
				rolling3:   { name: "rolling3",   display: "r3",  rolling: true,  reshuffle: false, remove: false },

				reshuffle1: { name: "reshuffle1", display: "re1", rolling: false, reshuffle: true,  remove: false },
				reshuffle2: { name: "reshuffle2", display: "re2", rolling: false, reshuffle: true,  remove: false },
				reshuffle3: { name: "reshuffle3", display: "re3", rolling: false, reshuffle: true,  remove: false },

				remove1:    { name: "remove1",    display: "rm1", rolling: false, reshuffle: false, remove: true },
				remove2:    { name: "remove2",    display: "rm2", rolling: false, reshuffle: false, remove: true },
				remove3:    { name: "remove3",    display: "rm3", rolling: false, reshuffle: false, remove: true },
			}

			@deck = Deck.new(
				# Turn shuffle off so we can make sure things at working
				actually_shuffle: false,
			)
		end

		def test_draw_cards()
			@deck.set_deck([
				@test_cards[:normal1],
				@test_cards[:normal2],
				@test_cards[:normal3],
			])

			# So we can make sure it's not shuffled
			@deck.shuffled = false

			assert_equal(@test_cards[:normal1], @deck.roll())
			assert_false(@deck.shuffled)
			assert_equal(@test_cards[:normal2], @deck.roll())
			assert_false(@deck.shuffled)
		end

		def test_draw_past_end()
			@deck.set_deck([
				@test_cards[:normal1],
				@test_cards[:normal2],
				@test_cards[:normal3],
			])

			# So we can make sure it's not shuffled
			@deck.shuffled = false

			assert_equal(@test_cards[:normal1], @deck.roll())
			assert_false(@deck.shuffled)
			assert_equal(@test_cards[:normal2], @deck.roll())
			assert_false(@deck.shuffled)
			assert_equal(@test_cards[:normal3], @deck.roll())
			assert_false(@deck.shuffled)

			# This should trigger a shuffle
			assert_equal(@test_cards[:normal1], @deck.roll())
			assert_true(@deck.shuffled)
		end

		def test_set_bad_cards()
			e = assert_raises(::GHDeck::Deck::Exception) do
				@deck.set_deck([
					{:a => 1}
				])
			end

			assert_equal('Each card definition needs to contain name, display, rolling, reshuffle, and remove', e.message)
		end

		def test_add_card()
			@deck.set_deck([
				@test_cards[:normal1],
			])

			# So we can make sure it's not shuffled
			@deck.shuffled = false

			@deck.add_card(
				{ name: "test", display: "test", rolling: false, reshuffle: false, remove: false },
			)

			# Make sure it's shuffled
			assert_true(@deck.shuffled)

			# Burn the other card
			@deck.roll()

			# Check if the card is inserted
			assert_equal('test', @deck.roll()[:name])
		end

		def test_end_round_normal()
			@deck.set_deck([
				@test_cards[:normal1],
				@test_cards[:normal2],
				@test_cards[:normal3],
			])

			@deck.shuffled = false

			assert_equal(@test_cards[:normal1], @deck.roll())
			@deck.end_round()
			assert_false(@deck.shuffled)

			assert_equal(@test_cards[:normal2], @deck.roll())
			@deck.end_round()
			assert_false(@deck.shuffled)

			assert_equal(@test_cards[:normal3], @deck.roll())
			@deck.end_round()
			assert_false(@deck.shuffled)
		end

		def test_remove()
			@deck.set_deck([
				@test_cards[:normal1],
				@test_cards[:remove1],
				@test_cards[:normal2],
			])

			# Draw the three cards
			assert_equal(@test_cards[:normal1], @deck.roll())
			assert_equal(@test_cards[:remove1], @deck.roll())
			assert_equal(@test_cards[:normal2], @deck.roll())

			# After a shuffle happens, there should only be two cards
			assert_equal(@test_cards[:normal1], @deck.roll())
			assert_equal(@test_cards[:normal2], @deck.roll())
		end

		def test_end_round_shuffle()
			@deck.set_deck([
				@test_cards[:normal1],
				@test_cards[:reshuffle1],
				@test_cards[:normal2],
				@test_cards[:reshuffle2],
			])

			@deck.shuffled = false

			# End round after 1 normal card
			assert_equal(@test_cards[:normal1], @deck.roll())
			@deck.end_round()
			assert_false(@deck.shuffled)

			# End second round after 1 reshuffle card
			assert_equal(@test_cards[:reshuffle1], @deck.roll())
			@deck.end_round()
			assert_true(@deck.shuffled)

			# Do three turns then end round
			assert_equal(@test_cards[:normal1], @deck.roll())
			assert_equal(@test_cards[:reshuffle1], @deck.roll())
			assert_equal(@test_cards[:normal2], @deck.roll())
			@deck.end_round()
			assert_true(@deck.shuffled)

			# Make sure we're back at the start
			assert_equal(@test_cards[:normal1], @deck.roll())
		end

		def test_reset_deck()
			@deck.set_deck([
				@test_cards[:normal1],
				@test_cards[:remove1],
				@test_cards[:normal2],
				@test_cards[:remove2],
			])

			# Draw a card to make sure it resets the index
			assert_equal(@test_cards[:normal1], @deck.roll())

			@deck.reset_deck()

			# Make sure it's just the two normal cards
			assert_equal(@test_cards[:normal1], @deck.roll())
			assert_equal(@test_cards[:normal2], @deck.roll())
			assert_equal(@test_cards[:normal1], @deck.roll())
			assert_equal(@test_cards[:normal2], @deck.roll())
		end

		def test_get()
			deck = [
				@test_cards[:normal1],
				@test_cards[:normal2],
			]

			@deck.set_deck(deck)

			index, new_deck = @deck.get()
			assert_equal(0, index)
			assert_equal(deck, new_deck)

			@deck.roll()

			index, new_deck = @deck.get()
			assert_equal(1, index)
			assert_equal(deck, new_deck)
		end

		def test_extra_card_args()
			entry = { name: "normal1", display: "n1",  rolling: false, reshuffle: false, remove: false, test_field: 'abc' }
			@deck.set_deck([entry])

			assert_equal(entry, @deck.roll())
		end

		def test_shuffle_remainder_of_deck_when_adding()
			# TODO
			assert_true(false)
		end
	end
end
