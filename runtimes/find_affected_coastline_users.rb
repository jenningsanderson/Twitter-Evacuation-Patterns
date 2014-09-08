#
# Find all users in the affected coastline area
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


#Get the Bounding Box:
geojson_box = File.read('../GeoJSON/affected_coastline_4k.geojson')
rgeo_geojson = RGeo::GeoJSON.decode(geojson_box, :json_parser => :json)
bounding_box = GEOFACTORY.parse_wkt( rgeo_geojson[0].geometry.to_s )

puts "Successfully processed Coastline Box. area is: #{bounding_box.area/1000000} square km"

#Iterate over users where we know their path was affected
results = Twitterer.where(
                :unclassifiable.ne => true, #We need to know if we can process them
                :hazard_level_before.lte => 50,  #Users that are in the bounding box
                :"cluster_locations.before_home".ne => nil
).limit(nil)

puts "Found #{results.count} results, now processing"

updated_users = 0

results.each_with_index do |user, index|

	#Cast their location points
	before_home_array = user.cluster_locations[:before_home]

	before_home_pnt = GEOFACTORY.point(before_home_array[0], before_home_array[1] )

	if before_home_pnt.within? bounding_box
		updated_users +=1
		
		user.hazard_level_before = 36 #This means they were in coastline area
	end

	user.save

	if (index % 10).zero?
		print "."
	elsif (index%101).zero?
		print "#{updated_users} / #{index+1}"
	end
end

puts "Updated Users: #{updated_users}"
