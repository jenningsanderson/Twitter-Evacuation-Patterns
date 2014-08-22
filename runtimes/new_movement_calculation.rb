#
# New Movement Calculation for updated users.
#

require 'rubygems'
require 'bundler/setup'

require 'active_support'
require 'active_support/deprecation'

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Static Setup
MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'


results = Twitterer.where( 

  #:tweet_count.gte => 50,
  #:affected_level_before => 1

  #:handle.in => ["Bacon_Season", "EffinwitESH", "FoxyQuant", "JayresC", "KelACampbell", "LynnKatherinex3", "Max_Not_Mark", "kriistinax33", "fredstardagreat", "honeyberk", "knowacki", "lmarks19", "marietta_amato", "mattgunn", "petemall", "ricardovice", "rishegee", "robertkohr", "rockawaytrading", "uthmanbaksh", "yawetse", "PhanieMoore", "RayDelRae", "SlaintePaddys", "anneeoanneo", "_dbourret", "c4milo", "contentmode", "cooper_smith", "derrickc82", "eelain212", "ericabrooke12"]
  #:handle.in => [ "dpickering11","robertkohr", "Xsd","jessnic0le","aimerlaterre","SteveScottWCBS","MegEHarrington","nicolelmancini","DomC_","lisuhc"]
  :issue => 100,


  ).limit(nil).sort(:tweet_count)

puts "Found #{results.count} results..."
evac_count = 0

results.each do |user|
  puts "User: #{user.handle}..."

  user.new_location_calculation

  user.issue = 80

  user.save #Write the user back to the collection

end