
require_relative '../models/Containers'

describe BoundingBox do
	it "Can successfully parse a GeoJSON file into a bbox geometry" do
		bbox = BoundingBox.new(geojson: "GeoJSON/NJ_BoundaryIslands.geojson")
		
		puts bbox.geometry.area
	end
end