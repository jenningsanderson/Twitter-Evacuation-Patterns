#
# Reprocess for the NCAR Bounding Box (Ignoring my older bounding box)
# Used for testing
#

require 'mongo_mapper'
require 'epic-geo'
require 'rgeo'
require 'rgeo-geojson'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Static Setup
# MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
# MongoMapper.database = 'sandygeo'

# geojson_string = %{"{
#   "type": "Polygon",
#   "coordinates": [[
#     [-76.055416,36.988536],
#     [-76.416506,39.084008],
#     [-73.872974,41.654353],
#     [-70.874853,41.732875],
#     [-76.055416,36.988536]
#     ]]
#   }"
# }

ncar_geojson = File.read('../GeoJSON/NCAR_BoundingBox.GeoJSON')

rgeo_geojson = RGeo::GeoJSON.decode(ncar_geojson, :json_parser => :json)

ncar_bounding_box = GEOFACTORY.parse_wkt( rgeo_geojson[0].geometry.to_s )

# #Now iterate over the Twitterer collection to update the affected_level parameter (Set it to 4 if they fall in this zone)
# Twitterer.where(
#                   :affected_level.gte => 2, #Don't look at 1, because we know they are already in there.
#                 ).limit(nil).each_with_index do |user, index|

#   #Check it
#   if GEOFACTORY.point(user.before[0], user.before[1]).within? boundary
#     before_counter +=1
#     user.affected_level = 4
#     user.save
#   end
  
#   if (index % 100).zero?
#     print "."
#   elsif (index%1001).zero?
#     print "#{path_counter} / #{index+1}"
#   end
# end
