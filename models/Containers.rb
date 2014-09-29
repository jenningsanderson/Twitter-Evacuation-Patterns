#
# This file contains containers for appropriate querying
#
#

require 'rgeo'
require 'rgeo-geojson'

class Container #Can I inherit geo methods here, or is that poor form?

	attr_reader :factory

	def initialize(args)
		@name = args[:name]
		post_initialize(args)
	end
end



class BoundingBox < Container

	attr_reader :geojson, :geometry, :features, :factory

	def initialize(args)
		@geojson = args[:geojson]

		@factory = RGeo::Geographic.simple_mercator_factory #Perhaps we'll use a smarter factory in a bit
		super(args)
	end

	def post_initialize(args)

		if geojson
			load_geojson(geojson)
		end

	end
	
	def load_geojson(geojson_file)
		geo_json = File.read(geojson_file)
		rgeo_geo = RGeo::GeoJSON.decode(geo_json, json_parser: :json)
		
		@features=rgeo_geo
		
		@geometry=factory.parse_wkt(features.first.geometry)
	end
end


# #Get the NCAR bounding box:
# ncar_geojson_box = 
# ncar_rgeo_geojson = 
# ncar_bounding_box = GEOFACTORY.parse_wkt( ncar_rgeo_geojson[0].geometry.to_s )

# puts "Successfully processed NCAR bounding box, area is: #{ncar_bounding_box.area/1000000} square km"

# # #Get the NYC evacuation zones:
# # nyc_geojson_file = File.read('../GeoJSON/NYC_EvacZones.GeoJSON')
# # raw_evac_zones = RGeo::GeoJSON.decode(nyc_geojson_file, :json_parser => :json)
# # evac_zones = raw_evac_zones.group_by{|zone| zone['CAT1NNE']}
# # zone_arrays = {}
# # ["A","B","C"].each{|zone|
# # 	zone_arrays[zone] = []
# # 	evac_zones[zone].each do |part|
# # 		zone_arrays[zone] << GEOFACTORY.parse_wkt(part.geometry.to_s)
# 	end
# }