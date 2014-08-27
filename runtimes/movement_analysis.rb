#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'


#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

results = Twitterer.where( 
	
	:hazard_level_before => 10,
	:shelter_in_place.ne => true

).limit(nil).sort(:tweet_count).limit(50)

puts "Found #{results.count} users"

results.each_with_index do |user, index|

	puts user.handle
	puts "------------------"
	
	unless user.shelter_in_place
		user.new_location_calculation
	end

	puts "==================\n\n"

end
