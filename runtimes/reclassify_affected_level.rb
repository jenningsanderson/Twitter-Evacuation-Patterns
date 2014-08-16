#
# Reprocess for the NCAR Bounding Box (Ignoring my older bounding box)
# 
# Sets an affected level for each time bin.

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


string_vals = ["before", "during", "after"]


#Now iterate over the entire collection
Twitterer.where(
				
				:tweet_count.gte => 1 #All users
                
                ).limit(nil).each_with_index do |user, index|

	#Set the new defaults for all users
	user.affected_level_before = 100
	user.affected_level_during = 100
	user.affected_level_after  = 100


	#Check that their path intersects the bounding box at any point, if not, then move on!
	if user.user_path.intersects? ncar_bounding_box
		
		user.path_affected = true

		#Cast the before, during, after points to a point object
		before = GEOFACTORY.point(user.before[0], user.before[1])
		during = GEOFACTORY.point(user.during[0], user.during[1])
		after  = GEOFACTORY.point(user.after[0],  user.after[1])

		[before, during, after].each_with_index do |time_frame, index| #This is x3 time.

			if time_frame.within? ncar_bounding_box
				user.instance_eval "affected_level_#{string_vals[index]} = 10" #user.affected_level_before = 10 if their before value falls into bounding box.  Straight forward?

				#Now it's time to investigate if that value is within an actual evacuation zone.
				["A", "B", "C"].each_with_index do |zone, zone_index| #Will be 0,1,2

					zone_arrays[zone].each do |zone_geometry| #Iterate through each of the elements of the zone
						
						if time_frame.within? zone_geometry #Check if the point is within the zone geom
							user.instance_eval "affected_level_#{string_vals[index]} = #{zone_index+1}" #Will be 1 for A, 2 for B, and 3 for C.
						end
					end
				end
			end
		end
	else
		user.path_affected = false
	end

	user.save

	if (index % 100).zero?
		print "."
	elsif (index%1001).zero?
		print "#{path_counter} / #{index+1}"
	end
end
