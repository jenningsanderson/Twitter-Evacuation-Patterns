require 'rgeo-shapefile'
require 'geo_ruby'
require 'geo_ruby/shp'
require 'json'


class tweet_json_reader

	def initialize( in_file )



	end


end

class tweet_shapefile
	attr_reader :file_name

	def initialize(file_name)
		@file_name = file_name
	end

	def write_shapefile


	end

end

puts "This is a test of reading a shapefile"
shape = RGeo::Shapefile::Reader.open('../lab3/data/interestAreas.shp')
shape.each do |record|
	puts record.geometry.area
  end
puts shape.open?
shape.close
puts shape.open?




## This one can read and write... but none of it is very straightforward.:


GeoRuby::Shp4r::ShpFile.open('../lab3/data/interestAreas.shp') do |shp|
	shp.each do |shape|
		geom = shape.geometry #a GeoRuby SimpleFeature
			puts "BOUNDING BOX: #{geom.bounding_box.inspect }\n"#I can get bounding box, but I can't calculate area?
		att_data = shape.data #a Hash
		puts "Attribute data: #{att_data.inspect}"
		shp.fields.each do |field|
			puts "Field: #{field.inspect}"
			puts att_data[field.name]
		end
	end
end
