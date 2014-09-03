#
# Find users in the NJ Bounary Islands zone
# 
# Sets a hazard_level_before for just the before point

require 'mongo_mapper'
require 'epic-geo'
require 'rgeo'
require 'rgeo-geojson'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'


#Get the NCAR bounding box:
ncar_geojson_box = File.read('../GeoJSON/NCAR_BoundingBox.GeoJSON')
ncar_rgeo_geojson = RGeo::GeoJSON.decode(ncar_geojson_box, :json_parser => :json)
ncar_bounding_box = GEOFACTORY.parse_wkt( ncar_rgeo_geojson[0].geometry.to_s )

puts "Successfully processed NCAR bounding box, area is: #{ncar_bounding_box.area/1000000} square km"

#Get the NYC evacuation zones:
nyc_geojson_file = File.read('../GeoJSON/NYC_EvacZones.GeoJSON')
raw_evac_zones = RGeo::GeoJSON.decode(nyc_geojson_file, :json_parser => :json)
evac_zones = raw_evac_zones.group_by{|zone| zone['CAT1NNE']}
zone_arrays = {}
["A","B","C"].each{|zone|
	zone_arrays[zone] = []
	evac_zones[zone].each do |part|
		zone_arrays[zone] << GEOFACTORY.parse_wkt(part.geometry.to_s)
	end
}

puts "Successfully processed the NYC Evac zones."

#Iterate over users where we know their path was affected
results = Twitterer.where(
				:path_affected => true,
                :unclassifiable => nil, 	#We need to know if we can process them
                :clusters_per_day => nil,
                :hazard_level_before => 100
).limit(nil)

puts "Found #{results.count} results, now processing"

updated_users = 0
error_count = 0

results.each_with_index do |user, index|

	#Cast their location points
	before_home_array = user.cluster_locations[:before_home]

	before_home_pnt = GEOFACTORY.point(before_home_array[0], before_home_array[1] )

	updated_users +=1
	if before_home_pnt.within? ncar_bounding_box
		
		user.hazard_level_before = 50 #Means they were in the ncar_bounding_box

		#Now it's time to investigate if that value is within an actual evacuation zone.
		["A", "B", "C"].each_with_index do |zone, zone_index| #Will be 0,1,2

			zone_arrays[zone].each do |zone_geometry| #Iterate through each of the elements of the zone
				
				if before_home_pnt.within? zone_geometry #Check if the point is within the zone geom
					user.hazard_level_before = (zone_index+1)*10
				end
			end
		end
	else
		user.hazard_level_before = 100
	end

	user.issue = 2000
	user.save

	if (index % 10).zero?
		print "."
	elsif (index%101).zero?
		print "#{error_count} | #{updated_users} / #{index+1}"
	end
end

puts "Updated Users: #{updated_users}"
