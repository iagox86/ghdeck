$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ghdeck"

require 'simplecov'
SimpleCov.start do
	add_filter '/test/'
end

require 'ghdeck/logger'
::GHDeck::Logger.set_level(level: ::GHDeck::Logger::FATAL)

require 'test/unit'
