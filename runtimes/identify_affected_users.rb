#
# Find all users in the affected coastline area, depending on their risk level
# 

require_relative '../config.rb'

include EpicGeo::Writers

results = Twitterer.where( :base_cluster_risk => 10 )
count = results.count
puts "Found #{count} users"

filename = "NYC_ZoneA"

#Start a file
geojson_file = EpicGeo::Writers::GeoJSONWriter.new("../GeoJSON/exports/#{filename}")
geojson_file.write_header

results.each_with_index do |user, index|

	geometry = user.base_cluster_point

	properties = {handle: user.handle, risk: RISK_LEVELS[user.base_cluster_risk]}

	geojson_file.write_feature(geometry, properties)

	if (index%100).zero?
		puts "------#{index} / #{count}-----"
	end
end

geojson_file.write_footer