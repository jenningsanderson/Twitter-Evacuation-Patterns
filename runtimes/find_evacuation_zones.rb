#
# Find Official Evacuation Zones
#
# Using an official evacuation zone, find users which fall within it.
#

require 'mongo_mapper'
require 'epic-geo'
require 'rgeo'
require 'rgeo-geojson'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Prepare a KML file
# kml_outfile = KMLAuthor.new("../exports/median_locations.kml")
# kml_outfile.write_header("Sandbox Location Testing")
# write_3_bin_styles(kml_outfile.openfile)

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

#Need to make a polygon from the GeoJSON
#File:
geojson_file = File.read('../GeoJSON/NYC_EvacZones.GeoJSON')
raw_evac_zones = RGeo::GeoJSON.decode(geojson_file, :json_parser => :json)

evac_zones = raw_evac_zones.group_by{|zone| zone['CAT1NNE']}

geom = evac_zones["A"][0].geometry.to_s

zone_a_1 = GEOFACTORY.parse_wkt(geom)

puts zone_a_1.class

puts zone_a_1.area

# puts evac_zones["A"].collect{|parts| parts["geom"]}


#evac_a = RGeo::Feature::Polygon.new()

# evac_a = GEOFACTORY.polygon(evac_zones['A'].collect{|parts| parts["geom"]})

# puts evac_a



# boundary_points = []
#
# points.each do |point|
#   boundary_points << GEOFACTORY.point(point[0],point[1])
# end
#
# boundary = GEOFACTORY.multi_point(boundary_points).convex_hull
#
# path_counter = 0
# before_counter = 0
#
# #Search the Twitterer collection
# Twitterer.where( :affected_level => 10,
#                  :tweet_count.lt => 500,
#                  :tweet_count.gte => 200
#                 ).limit(nil).each_with_index do |user, index|
#   #print "User: #{user.handle}..."
#
#   user.affected_level = 10
#
#   #Check it
#   val = user.user_path.intersects? boundary
#   if val
#     path_counter+=1
#     user.affected_level = 5
#     unless user.before[0].nil?
#       if GEOFACTORY.point(user.before[0], user.before[1]).within? boundary
#         before_counter +=1
#         user.affected_level = 2
#       end
#     end
#   end
#
#   user.save
#
#   if (index % 100).zero?
#     print "."
#   elsif (index%1001).zero?
#     print "#{path_counter} / #{index+1}"
#   end
# end
