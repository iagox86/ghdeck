$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/lib'))

require 'ghdeck'
require 'ghdeck/logger'

::GHDeck::Logger.set_level_from_string(level: 'debug')

require 'ghdeck/server'
::GHDeck::Server.run!()
