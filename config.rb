#
# This should be the only file that is required for the rest of the program
#
#
#
#

#Wile we're at it, lets just require rgeo and set a factory...
require 'rgeo'
FACTORY = RGeo::Geographic.simple_mercator_factory


#Breaking these requirements out of Twitterer model and into the config:
#EpicGeo is getting completely refactored, but eventually this will just be require 'EpicGeo'
require_relative '/Users/jenningsanderson/Documents/epic-geo/lib/epic_geo'

#This is our heavy lifter --- bad idea? maybe
require_relative 'models/twitterer'

require_relative 'modules/time_processing'
# Include TimeProcessing

require_relative 'modules/functions'
# Include CustomFunctions

TIMES = {event: Date.new(2012,10,29) }

RISK_LEVELS = {
	10 	=> 	"NYC Zone A",
	11 	=> 	"NYC Zone B",
	12 	=> 	"NYC Zone C",
	20 	=> 	"NJ Barrier Coast",
	50 	=> 	"NCAR Bounding Box",
	100 => 	"Outside NCAR Bounding Box"
}

#Connect to the database
MongoMapper.connection = Mongo::Connection.new# (Local)
MongoMapper.database = 'sandygeo'
