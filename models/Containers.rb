#
# This file contains containers for appropriate querying
#
#

require 'rgeo'
require 'rgeo-geojson'

class Container #Can I inherit geo methods here, or is that poor form?

	def initialize(args)
		@name = args[:name]
		post_initialize(args)
	end

	def post_initialize(args)
		nil
	end
end



class BoundingBox < Container

	attr_reader :geo_json, :geometry

	def initialize(args)
		@geo_json = args[:geojson]
		super(args)
	end

	def post_initialize(args)
		if geo_json
			load(geojson(geojson))
		end
	end

	def load_geojson(args)
		geo_json = File.read('../GeoJSON/NCAR_BoundingBox.GeoJSON')
		rgeo_geo = RGeo::GeoJSON.decode(geo_json, :json_parser => :json)
		@geometry=rgeo_geo
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