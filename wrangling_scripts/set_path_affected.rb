#
# Process the NCAR Bounding Box & NYC Evacuation Zones
# 
# Sets a hazard_level_before for just the before point

require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'

require 'mongo_mapper'
require 'epic-geo'
require 'rgeo'
require 'rgeo-geojson'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Static Setup
MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

#Get the NCAR bounding box:
ncar_geojson_box = File.read('../GeoJSON/NCAR_BoundingBox.GeoJSON')
ncar_rgeo_geojson = RGeo::GeoJSON.decode(ncar_geojson_box, :json_parser => :json)
ncar_bounding_box = GEOFACTORY.parse_wkt( ncar_rgeo_geojson[0].geometry.to_s )

puts "Successfully processed NCAR bounding box, area is: #{ncar_bounding_box.area/1000000} square km"

#Now iterate over the entire collection
results = Twitterer.where(

				:path_affected => nil #We need to know if we can process them
                
                ).limit(nil)

puts "Found #{results.count} results, now processing"

results.each_with_index do |user, index|

	#Check the tweets are in order before we do this...
	tweet_dates = user.tweets.collect{|tweet| tweet.date}

	unless (tweet_dates == tweet_dates.sort)
		ordered_tweets = user.tweets.sort_by{|tweet| tweet.date}
		user.tweets = ordered_tweets
	end

	#Check that their path intersects the bounding box at any point, if not, then move on!
	if user.user_path.intersects? ncar_bounding_box	
		user.path_affected = true
	else
		user.path_affected = false
		user.unclassifiable = true
	end
	user.save
end
