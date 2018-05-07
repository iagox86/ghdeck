##
# logger.rb
# By Ron
# 2018-01
#
# This is a simple wrapper around the ruby Logger class to make it a singleton
# (since it's a little weird to create new instances all over the place)
##
require 'logger'

module GHDeck
  class Logger < ::Logger
    @@instance = nil

    private
    def initialize(level:)
      super(STDERR)
      @level = level
    end

    public
    def self.instance(level: nil)
      if(@@instance)
        if(level)
          @@instance.level = level
        end
        return @@instance
      end

      @@instance = Logger.new(level: (level || ::Logger::INFO))
      return @@instance
    end

    public
    def self.set_level(level:)
      self.instance(level: level)
    end

    public
    def self.set_level_from_string(level:)

      self.set_level(level: ::Logger::DEBUG)
      if(level =~ /info/i)
        self.set_level(level: ::Logger::INFO)
      elsif(level =~ /warn/i)
        self.set_level(level: ::Logger::WARN)
      elsif(level =~ /error/i)
        self.set_level(level: ::Logger::ERROR)
      elsif(level =~ /fatal/i)
        self.set_level(level: ::Logger::FATAL)
      end
    end
  end
end
