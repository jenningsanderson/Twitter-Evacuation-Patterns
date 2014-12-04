#
# This should be the only file that is required for the rest of the program
#

#Add the directory to the loadpath
$:.unshift File.dirname(__FILE__)

#Wile we're at it, lets just require rgeo and set a factory...
require 'rgeo'
#Give us more accurate calculations on data for New York & New Jersey
FACTORY = RGeo::Geographic.projected_factory(projection_proj4: '+proj=utm +zone=18 +datum=NAD27 +units=m +no_defs ')
#FACTORY = RGeo::Geographic.simple_mercator_factory #The basic factory for web mercator data

#Breaking these requirements out of Twitterer model and into the config:
#EpicGeo is getting completely refactored, but eventually this will just be require 'EpicGeo'
require '/Users/jenningsanderson/Documents/epic-geo/lib/epic_geo'

#This is our heavy lifter --- bad idea? maybe
require 'models/twitterer'

require 'modules/time_processing'
# Include TimeProcessing

require 'modules/functions'
# Include CustomFunctions

require 'modules/user_behavior'

TIMES = {
	event: 		Date.new(2012,10,29),
	two_days:   Date.new(2012,11,1), 
	one_week: 	Date.new(2012,11,7)
		}

RISK_LEVELS = {
	10 	=> 	"NYC Zone A",
	11 	=> 	"NYC Zone B",
	12 	=> 	"NYC Zone C",
	20 	=> 	"NJ Barrier Coast",
	50 	=> 	"NCAR Bounding Box",
	100 => 	"Outside NCAR Bounding Box"
}

#Connect to the database
MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo2'
