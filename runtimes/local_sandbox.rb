#
# Local Testing
#
# Used for running an update locally on the Server.
#
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
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

results = Twitterer.where( 
	
	:hazard_level_before => 36,
	#:evac_conf.gt => 50,
	:handle => "iKhoiBui"

).limit(10).each

results.each_with_index do |user, index|

	puts user.sanitized_handle
	puts user.critical_points_to_json_hash
	puts "\n\n"
	puts user.tweets_to_geojson(Time.new(2012,10,22), Time.new(2012,11,04))

	# if (index % 10).zero?
	# 	print "."
	# elsif (index%101).zero?
	# 	print "#{index}"
	# end

end
