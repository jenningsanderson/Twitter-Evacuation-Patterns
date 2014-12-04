#=A wrapper on the EpicGeo::Writers::GeoJSONWriter for Tweet/Point objects.
#
#
class TweetWriter

	attr_reader :filename, :geojson_outfile, :write_directory

	attr_accessor :tweets

	def initialize(args)
		@filename = args[:filename]

		@write_directory = args[:write_directory] || "../exports/"

		@geojson_outfile = EpicGeo::Writers::GeoJSONWriter.new("#{write_directory}#{filename}")
		geojson_outfile.write_header

		@tweets = []
	end

	def add_tweet(tweet, coding={})
		tweets << tweet
		geojson_outfile.literal_write_feature(tweet.as_geojson.merge(coding).to_json)
	end

	def add_line
		line = {:type => "LineString", :coordinates=> @tweets.collect{|t| t.coordinates["coordinates"]}}
		geojson_outfile.write_feature(line, {:handle=>tweets.first.handle})
	end

	def add_point(geometry, properties)
		geojson_outfile.write_feature geometry, properties 
	end

	def close
		geojson_outfile.write_footer
	end

end
