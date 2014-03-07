require 'rgeo-shapefile'
require 'geo_ruby'
require 'geo_ruby/shp'
require 'json'


class Tweet_JSON_Reader
	attr_reader :json_filename

	def initialize( in_file )
		@json_filename = in_file
	end

end

class Tweet_Shapefile
	attr_reader :file_name

	def initialize(file_name)
		unless file_name =~ /\.shp$/
			file_name << '.shp'
		end
		@file_name = file_name
	end

	def create_point_shapefile
		@shapefile = GeoRuby::Shp4r::ShpFile.create(@file_name, GeoRuby::Shp4r::ShpType::POINT,[])
	end

	def add_point(point)

		@shapefile
	end

end

if __FILE__ == $0
	tweet = Tweet_Shapefile.new('sandy_tweets_sample')
	tweet.create_point_shapefile
end

# puts "This is a test of reading a shapefile"
# shape = RGeo::Shapefile::Reader.open('../lab3/data/interestAreas.shp')
# shape.each do |record|
# 	puts record.geometry.area
#   end
# puts shape.open?
# shape.close
# puts shape.open?




## This one can read and write... but none of it is very straightforward.:

#
# GeoRuby::Shp4r::ShpFile.open('../lab3/data/interestAreas.shp') do |shp|
# 	shp.each do |shape|
# 		geom = shape.geometry #a GeoRuby SimpleFeature
# 			puts "BOUNDING BOX: #{geom.bounding_box.inspect }\n"#I can get bounding box, but I can't calculate area?
# 		att_data = shape.data #a Hash
# 		puts "Attribute data: #{att_data.inspect}"
# 		shp.fields.each do |field|
# 			puts "Field: #{field.inspect}"
# 			puts att_data[field.name]
# 		end
# 	end
# end

#,ShpType::POINT,[Dbf::Field.new("Hoyoyo","C",10)])
