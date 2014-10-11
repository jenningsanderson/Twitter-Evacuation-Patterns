#
# Identify New Jersey users who may have evacuated 
#
#

require_relative '../config.rb'

include EpicGeo::Writers

include TimeProcessing #Gives access to the tweet_regularity functions

results = Twitterer.where( :base_cluster_risk => 20 )
count = results.count
puts "Found #{count} users"

filename = "NJ_Evacuators"

#Start a geojson file
geojson_file = EpicGeo::Writers::GeoJSONWriter.new("../GeoJSON/exports/#{filename}")
geojson_file.write_header

results.each_with_index do |user, index|

	#Get their base_cluster point
	base_cluster = user.base_cluster_point

	#Now use the same logic to find their best during storm cluster
	c_val 			= 0.0;
	storm_cluster 	= nil
	user.clusters.each do |cluster_id, tweets|
		pert_tweets = tweets.select{ |tweet| tweet.date > Date.new(2012,10,29) and tweet.date < Date.new(2012,11,07)}
		this_cluster_score = tweet_regularity(pert_tweets)
		if this_cluster_score > c_val
			c_val = this_cluster_score
			storm_cluster = cluster_id.to_s
		end
	end

	storm_p = user.cluster_locations[storm_cluster.to_s]
	unless storm_p.nil?
		storm_point = FACTORY.point(storm_p[0],storm_p[1])
		geometry = FACTORY.line_string([user.base_cluster_point, storm_point])
	end

	unless geometry.nil?
		properties = {handle: user.handle, risk: RISK_LEVELS[user.base_cluster_risk], distance: (geometry.length/1000)}
		geojson_file.write_feature(geometry, properties)
	end

	if (index%10).zero?
		puts "------#{index} / #{count}-----"
	end
end

geojson_file.write_footer