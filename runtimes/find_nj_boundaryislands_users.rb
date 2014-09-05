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
nj_geojson_box = File.read('../GeoJSON/NJ_BoundaryIslands.geojson')
nj_rgeo_geojson = RGeo::GeoJSON.decode(nj_geojson_box, :json_parser => :json)
nj_bounding_box = GEOFACTORY.parse_wkt( nj_rgeo_geojson[0].geometry.to_s )

puts "Successfully processed NJ Boundary Islands bounding box, area is: #{nj_bounding_box.area/1000000} square km"

#Iterate over users where we know their path was affected
results = Twitterer.where(
                :unclassifiable.ne => true, #We need to know if we can process them
                :hazard_level_before => 50,  #Users that are in the bounding box
                :"cluster_locations.before_home".ne => nil
).limit(nil)

puts "Found #{results.count} results, now processing"

updated_users = 0

results.each_with_index do |user, index|

	#Cast their location points
	before_home_array = user.cluster_locations[:before_home]

	before_home_pnt = GEOFACTORY.point(before_home_array[0], before_home_array[1] )

	if before_home_pnt.within? nj_bounding_box
		updated_users +=1
		
		user.hazard_level_before = 40 #This means they were in NJ Barrier Islands
	end

	user.save

	if (index % 10).zero?
		print "."
	elsif (index%101).zero?
		print "#{updated_users} / #{index+1}"
	end
end

puts "Updated Users: #{updated_users}"
