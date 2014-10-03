#
# This should be the only file that is required for the rest of the program
#
#
#
#

#Wile we're at it, lets just require rgeo and set a factory...
require 'rgeo'
FACTORY = RGeo::Geographic.simple_mercator_factory



#This is our heavy lifter --- bad idea? maybe
require_relative 'models/twitterer'

#Connect to the database
MongoMapper.connection = Mongo::Connection.new# (Local)
MongoMapper.database = 'sandygeo'
