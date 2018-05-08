require 'test_helper'

require 'ghdeck/deck'

module GHDeck
	class DeckTest < ::Test::Unit::TestCase
		TEST_CARDS = {
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

		def test_draw_cards()
			deck = Deck.new(actually_shuffle: false, deck: [
				TEST_CARDS[:normal1],
				TEST_CARDS[:normal2],
				TEST_CARDS[:normal3],
			])

			# So we can make sure it's not shuffled
			deck.shuffled = false
			deck.reset = false

			assert_equal(TEST_CARDS[:normal1], deck.roll())
			assert_false(deck.shuffled)
			assert_false(deck.reset)
			assert_equal(TEST_CARDS[:normal2], deck.roll())
			assert_false(deck.shuffled)
			assert_false(deck.reset)
		end

		def test_draw_past_end()
			deck = Deck.new(actually_shuffle: false, deck: [
				TEST_CARDS[:normal1],
				TEST_CARDS[:normal2],
				TEST_CARDS[:normal3],
			])

			# So we can make sure it's not shuffled
			deck.shuffled = false
			deck.reset = false

			assert_equal(TEST_CARDS[:normal1], deck.roll())
			assert_false(deck.shuffled)
			assert_false(deck.reset)
			assert_equal(TEST_CARDS[:normal2], deck.roll())
			assert_false(deck.shuffled)
			assert_false(deck.reset)
			assert_equal(TEST_CARDS[:normal3], deck.roll())
			assert_false(deck.shuffled)
			assert_false(deck.reset)

			# This should trigger a shuffle
			assert_equal(TEST_CARDS[:normal1], deck.roll())
			assert_true(deck.shuffled)
			assert_true(deck.reset)
		end

		def test_set_bad_cards()
			e = assert_raises(::GHDeck::Deck::Exception) do
				Deck.new(actually_shuffle: false, deck: [
					{:a => 1}
				])
			end

			assert_equal('Each card definition needs to contain name, display, rolling, reshuffle, and remove', e.message)
		end

		def test_add_card()
			deck = Deck.new(actually_shuffle: false, deck: [
				TEST_CARDS[:normal1],
			])

			# So we can make sure it's not shuffled
			deck.shuffled = false
			deck.reset = false

			deck.add_card(
				{ name: "test", display: "test", rolling: false, reshuffle: false, remove: false },
			)

			# Make sure it's shuffled
			assert_true(deck.shuffled)
			assert_false(deck.reset)

			# Burn the other card
			deck.roll()

			# Check if the card is inserted
			assert_equal('test', deck.roll()[:name])
		end

		def test_end_round_normal()
			deck = Deck.new(actually_shuffle: false, deck: [
				TEST_CARDS[:normal1],
				TEST_CARDS[:normal2],
				TEST_CARDS[:normal3],
			])

			deck.shuffled = false
			deck.reset = false

			assert_equal(TEST_CARDS[:normal1], deck.roll())
			deck.end_round()
			assert_false(deck.shuffled)
			assert_false(deck.reset)

			assert_equal(TEST_CARDS[:normal2], deck.roll())
			deck.end_round()
			assert_false(deck.shuffled)
			assert_false(deck.reset)

			assert_equal(TEST_CARDS[:normal3], deck.roll())
			deck.end_round()
			assert_false(deck.shuffled)
			assert_false(deck.reset)
		end

		def test_remove()
			deck = Deck.new(actually_shuffle: false, deck: [
				TEST_CARDS[:normal1],
				TEST_CARDS[:remove1],
				TEST_CARDS[:normal2],
			])

			# Draw the three cards
			assert_equal(TEST_CARDS[:normal1], deck.roll())
			assert_equal(TEST_CARDS[:remove1], deck.roll())
			assert_equal(TEST_CARDS[:normal2], deck.roll())

			# After a shuffle happens, there should only be two cards
			assert_equal(TEST_CARDS[:normal1], deck.roll())
			assert_equal(TEST_CARDS[:normal2], deck.roll())
		end

		def test_end_round_shuffle()
			deck = Deck.new(actually_shuffle: false, deck: [
				TEST_CARDS[:normal1],
				TEST_CARDS[:reshuffle1],
				TEST_CARDS[:normal2],
				TEST_CARDS[:reshuffle2],
			])

			deck.shuffled = false
			deck.reset = false

			# End round after 1 normal card
			assert_equal(TEST_CARDS[:normal1], deck.roll())
			deck.end_round()
			assert_false(deck.shuffled)
			assert_false(deck.reset)

			# End second round after 1 reshuffle card
			assert_equal(TEST_CARDS[:reshuffle1], deck.roll())
			deck.end_round()
			assert_true(deck.shuffled)
			assert_true(deck.reset)

			# Do three turns then end round
			assert_equal(TEST_CARDS[:normal1], deck.roll())
			assert_equal(TEST_CARDS[:reshuffle1], deck.roll())
			assert_equal(TEST_CARDS[:normal2], deck.roll())
			deck.end_round()
			assert_true(deck.shuffled)
			assert_true(deck.reset)

			# Make sure we're back at the start
			assert_equal(TEST_CARDS[:normal1], deck.roll())
		end

		def test_reset_deck()
			deck = Deck.new(actually_shuffle: false, deck:[
				TEST_CARDS[:normal1],
				TEST_CARDS[:remove1],
				TEST_CARDS[:normal2],
				TEST_CARDS[:remove2],
			])

			# Draw a card to make sure it resets the index
			assert_equal(TEST_CARDS[:normal1], deck.roll())

			deck.shuffled = false
			deck.reset = false
			deck.reset_deck_to_clean()
			assert_true(deck.shuffled)
			assert_true(deck.reset)

			# Make sure it's just the two normal cards
			assert_equal(TEST_CARDS[:normal1], deck.roll())
			assert_equal(TEST_CARDS[:normal2], deck.roll())
			assert_equal(TEST_CARDS[:normal1], deck.roll())
			assert_equal(TEST_CARDS[:normal2], deck.roll())
		end

		def test_get()
			test_deck = [
				TEST_CARDS[:normal1],
				TEST_CARDS[:normal2],
			]

			deck = Deck.new(actually_shuffle: false, deck: test_deck)

			the_deck, the_discard = deck.get()
			assert_equal(test_deck, the_deck)
			assert_equal([], the_discard)

			deck.roll()

			the_deck, the_discard = deck.get()
			assert_equal([TEST_CARDS[:normal2]], the_deck)
			assert_equal([TEST_CARDS[:normal1]], the_discard)
		end

		def test_extra_card_args()
			entry = { name: "normal1", display: "n1",  rolling: false, reshuffle: false, remove: false, test_field: 'abc' }
			deck = Deck.new(actually_shuffle: false, deck: [entry])

			assert_equal(entry, deck.roll())
		end
	end
end
