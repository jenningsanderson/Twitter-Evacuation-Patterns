require 'rgeo-shapefile'
require 'geo_ruby'
require 'geo_ruby/shp'
require 'json'
require 'pp'

'''
Class for handling the a big tweet file from EPIC.
'''
class Tweet_JSON_Reader
	attr_reader :json_filename, :tweets

	# Pass in the file (json tweet per line), and a potential max line arg
	def initialize( in_file, max=nil, fields=nil)
			@json_filename = in_file

		unless max.nil?
			@tweets_file = File.open(@json_filename).first(max).each
		else
			@tweets_file = File.open(@json_filename).each
		end

		set_fields(fields)

		#Define an enumerator
		@tweets = Enumerator.new do |g|
			@tweets_file.each do |line|
				tweet = JSON.parse(line.chomp)
				g.yield extract_tweet(tweet)
			end
		end
	end

	def set_fields(interested_fields)
		unless interested_fields
			@fields = {
				:coords => '["geo"]["coordinates"]',
				:text   => '["text"]',
				:user_name => '["user"]["screen_name"]'
			}
		end
	end

	def extract_tweet(tweet_json)
		tweet = Hash.new
		@fields.each do |k,v|
			tweet[k] = instance_eval "#{tweet_json}#{v}"
		end
		return tweet
	end

	def get_tweet
		tweet = JSON.parse(@tweets_file.next.chomp)
		@fields.each do |k,v|
			this_tweet[k] = instance_eval "#{tweet}#{v}"
		end
		return this_tweet
	end
end


'''
This class makes a shapefile from tweets
'''
class Tweet_Shapefile
	attr_reader :file_name
	attr_accessor :fields

	def initialize(file_name)
		unless file_name =~ /\.shp$/
			file_name << '.shp'
		end
		@file_name = file_name
		@fields = {:usr_id_str=>['C',11], :handle=>['C',20], :text=>['C',140], :hashtags=>['C',100], :urls=>['C',100]}
	end

	def create_point_shapefile
		fields = []
		@fields.each do |k,v|
			fields << GeoRuby::Shp4r::Dbf::Field.new(k.to_s,v[0],v[1])
		end
		@shapefile = GeoRuby::Shp4r::ShpFile.create(@file_name, GeoRuby::Shp4r::ShpType::POINT,fields)

	end

	def add_point(p)
		@shapefile.transaction do |tr|
			tr.add(GeoRuby::Shp4r::ShpRecord.new(
				GeoRuby::SimpleFeatures::Point.from_x_y(p[:coords][1],p[:coords][0]),
				:handle.to_s => p[:user_name],
				:text.to_s => p[:text]))
		end
	end

	def add_line(line)
		@shapefile.transaction do |tr|
			pp p
			tr.add(GeoRuby::Shp4r::ShpRecord.new(
			GeoRuby::SimpleFeatures::Point.from_x_y(p[:coords][1],p[:coords][0]),
				:screen_name.to_s=>p[:screen_name],
				:text.to_s => p[:text]))
		end
		@shapefile.close
	end


	def method_missing(method_name)
		@shapefile.instance_eval "#{method_name}"
	end
end


#Global variables
sandy = '/Users/Shared/Sandy/geo_extract.json'
max   = 750

if __FILE__ == $0
	if ARGV[0]
		max = ARGV[0].to_i
	end
	puts "Running Tweet JSON to Shapefile, Parsing limit: #{max or 'none'}."

	# define the file reader
	t = Tweet_JSON_Reader.new(sandy, max)

	# make the shapefile
	tweet_shp = Tweet_Shapefile.new('sandy_tweets_sample')
	tweet_shp.create_point_shapefile

	#Add points to the file
	counter=0
	t.tweets.each do |tweet|
		tweet_shp.add_point(tweet)
		counter+=1
		if counter % 500 == 0
			puts counter
		end
	end
	tweet_shp.close
end

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
