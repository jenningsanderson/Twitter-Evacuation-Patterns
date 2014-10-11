#
# Write Clusters to GeoJSON file
# 

require_relative '../config.rb'

include EpicGeo::Writers

results = Twitterer.where( :base_cluster_risk => 20).limit(10)
count = results.count
puts "Found #{count} users"

filename = "NJ_Evacuators_Test"

#Start a file
geojson_file = EpicGeo::Writers::GeoJSONWriter.new("../GeoJSON/exports/#{filename}")
geojson_file.write_header

results.each_with_index do |user, index|

	user.cluster_locations.each do |cluster_id, location|
		geometry = FACTORY.point(location[0],location[1])
		properties = {handle: user.handle, cluster: cluster_id}
		if user.base_cluster == cluster_id
			properties[:home] = "true"
		end
		geojson_file.write_feature(geometry, properties)
	end

	geometry = user.week_one_linestring
	properties = {handle: user.handle}
	geojson_file.write_feature(geometry, properties)

	if (index%100).zero?
		puts "------#{index} / #{count}-----"
	end
end

geojson_file.write_footer