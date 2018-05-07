require 'json'

module GHDeck
	class Cards
		public
		class Exception < ::GHDeck::Exception
		end

		public
		def initialize(filename:)
			@filename = filename

			File.open(filename, 'r') do |f|
				@cards = JSON.parse(f.read())
			end
		end

		private
		def _save()
			@file.open(filename, 'w') do |f|
				f.write(@cards.to_json())
			end
		end

		# Shuffle the deck in-place and return to index 0
		public
		def add(id:, name:, display:, rolling:, reshuffle:, remove:, **args)
			@cards[id] = {
				name: name,
				display: display,
				rolling: rolling,
				reshuffle: reshuffle,
				remove: remove,
				**args,
			}

			_save()
		end

		public
		def remove(id:)
			@cards.delete(id)
			_save()
		end

		public
		def get()
			return @cards.clone
		end
	end
end
