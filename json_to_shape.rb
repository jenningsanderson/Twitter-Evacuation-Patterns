require 'rgeo-shapefile'
require 'geo_ruby'
require 'geo_ruby/shp'
require 'json'
require 'pp'

'''
Class for handling the giant file.
'''
class Tweet_JSON_Reader
	attr_reader :json_filename, :tweets

	def initialize( in_file, max=nil)
		@json_filename = in_file

		unless max.nil?
			@tweets_file = File.open(@json_filename).first(max).each
		else
			@tweets_file = File.open(@json_filename).each
		end
	end

	def get_tweet()
		tweet = JSON.parse(@tweets_file.next.chomp)

		return {	:coords => tweet["geo"]["coordinates"],
							:screen_name => tweet["user"]["screen_name"],
							:text => tweet["text"]}
	end

	def tweet_gen()
		@tweets_file.each do |tweet|

	# 	@tweets_file.each do |line|
	# 		tweet = JSON.parse(line.chomp)
	# 		this_tweet = []
	# 		this_tweet << tweet["user"]["id_str"] << tweet["text"] << tweet["geo"]["coordinates"]
	 	end
	end

	# 			@tweets[user_id] ||= {:name=>[],:coords=>[], :urls=>[], :hashtags=>[], :text=''}
	#
	# 			@tweets[user_id][:coords] 	<< tweet["geo"]["coordinates"]
	#
	# 			unless tweet["entities"]["urls"].nil?
	# 				tweet["entities"]["urls"].each do |url|
	# 					@tweets[user_id][:urls] << url["expanded_url"]
	# 				end
	# 			end
	# 			unless tweet["entities"]["hashtags"].nil?
	# 				tweet["entities"]["hashtags"].each do |hashtag|
	# 					@tweets[user_id][:hashtags] << hashtag["text"]
	# 				end
	# 			end
	# 			@tweets[user_id][:name] 		<< tweet["user"]["screen_name"]
	# 	end
	# end.lazy
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
		@fields = {:user_id_str=>11, :screen_name=>20, :text=>140, :hashtags=>100, :urls=>100}
	end

	def create_points_shapefile
		fields = []
		@fields.each do |k,v|
			fields << GeoRuby::Shp4r::Dbf::Field.new(k.to_s,"C",v)
		end
		@shapefile = GeoRuby::Shp4r::ShpFile.create(@file_name, GeoRuby::Shp4r::ShpType::POINT,fields)

	end

	def add_point(p)
		@shapefile.transaction do |tr|
			pp p
			tr.add(GeoRuby::Shp4r::ShpRecord.new(
				GeoRuby::SimpleFeatures::Point.from_x_y(p[:coords][1],p[:coords][0]),
				:screen_name.to_s=>p[:screen_name],
				:text.to_s => p[:text]))
		end
		@shapefile.close
	end

end

if __FILE__ == $0
	sandy = '/Users/Shared/Sandy/geo_extract.json'
	tweets = Tweet_JSON_Reader.new(sandy, max=10)
  #tweets.read_lines(max=10)

	#pp tweets.get_tweet
	tweet_shp = Tweet_Shapefile.new('sandy_tweets_sample')
	tweet_shp.create_points_shapefile

	tweet_shp.add_point(tweets.get_tweet)

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
