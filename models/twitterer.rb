# Twitterer Model
#
# This model describes a single user of Twitter.  It is currently
# setup for a user of the Hurricane Sandy dataset for evacuation analysis
#
# This class extends a MongoMapper document with embedded Tweet objects
#

require 'mongo_mapper'
require 'active_model'
require 'rgeo' 					# RGEO is stronger geo-processing
require 'georuby'				# Georuby allows for easier point => KML

#Load the geoprocessing algorithms
require_relative '../processing/geoprocessing'

class Twitterer

	#An RGeo Factory that is geospatially aware for all calculations
	@@tweet_factory = RGeo::Geographic.simple_mercator_factory

	#Enable access to points of interest
	attr_reader :points, :before, :during, :after

	#Extend MongoMapper
	include MongoMapper::Document

	#Key Twitterer Values needed
	key :id_str, 			String, :required => true, :unique => true
	key :handle, 			String
	key :tweet_count, Integer

	#Embed the following types of documents:
	many :tweets

	#Sandy Evacuation Specific values to track
	key :before, 			Array
	key :during, 			Array
	key :after, 			Array
	key :triangle_area, Float
	key :triangle_perimeter, Float
	key :before_during, Float
	key :during_after, Float
	key :before_after, Float

	#Update functions
	before_save { self.tweet_count = tweets.count }

# --------------------- GeoSpatial Functions ------------------------#

	#Create rgeo points array for all tweets
	def process_tweet_points
		@points = tweets.collect{ |tweet| tweet.as_point }
	end

	# Just the points as a multi_point geo object
	def user_points
		if @points.nil?
			process_tweet_points
		end
		@@tweet_factory.multi_point(@points)
	end

	#Create LineString of points
	def user_path
		if @points.nil?
			process_tweet_points
		end
		@userpath = @@tweet_factory.line_string(@points)
	end







# ----------------- Evacuation Analysis Functions -----------------#

	#The type is either 'before, during, or after'
	#coords is an array (lon, lat) to be saved...
	def set_poi(type, coords)
		instance_eval "@#{type} = #{coords}"
	end

	#The triangle analysis method
	def build_evac_triangle()
		unless @before.nil? or @during.nil? or @after.nil?
			before = @@tweet_factory.point(@before[0], @before[1])
			during = @@tweet_factory.point(@during[0], @during[1])
			after  = @@tweet_factory.point(@after[0],  @after[1])
			triangle_points = [ before, during, after, before]

			evac_ring = @@tweet_factory.linear_ring(triangle_points)
			evac_triangle = @@tweet_factory.polygon(evac_ring)

			@triangle_area = evac_triangle.area
			@triangle_perimeter = evac_ring.length

			@before_during = before.distance(during)
			@during_after  = during.distance(after)
			@before_after  = before.distance(after)
		end
	end

	# Split the tweets by dates in an array of dates
	def split_tweets_into_time_bins(time_bins)
		binned_tweets = []

		(0..time_bins.length-2).each do |index|
			binned_tweets << tweets.select do |tweet|
				tweet["date"] > time_bins[index] and tweet["date"] < time_bins[index+1]
			end
		end

		return binned_tweets
	end







	# --------------------- GeoJSON Functions -------------------------#
	#Returns a geojson MultiPoint object with each tweet as a point
	def individual_points_json
		points = tweets.collect{ |tweet| tweet.coordinates["coordinates"]}
		return {:type => "MultiPoint", :coordinates => points}
	end


	#Return a geojson Feature Collection of Individual Tweets
	def individual_tweets_json
		features = []
		tweets.each do |tweet|
			features << {:type => "Feature",
									 :geometry=> tweet["coordinates"],
									 :properties => {
											:text => tweet["text"],
											:created_at => tweet["date"],
											:handle => tweet["handle"].join(',')
										}}
		end
		return {:type => "FeatureCollection", :features => features}
	end

	#Return a geojson linestring of a user's tweet locations
	def full_user_path_json
		points = tweets.collect{ |tweet| tweet.coordinates["coordinates"]}
		return {:type => "LineString", :coordinates => points}
	end

	def full_median_point_json
		median_point = find_median_point tweets.collect do |tweet|
			tweet.coordinates["coordinates"]
		end

		return {:type => "Point", :coordinates => median_point}
	end






	# --------------------- KML Functions -------------------------#

	def userpath_as_epic_kml
		linestring = GeoRuby::SimpleFeatures::LineString.from_coordinates(
			tweets.collect{|tweet| tweet.coordinates["coordinates"]} )

		{:name 			=> handle,
		 :geometry => linestring,
		}
	end

	# A helper function to convert a point to epic-KML
	def point_as_epic_kml(name, x, y, style=nil)
		{ :name => name,
			:style => style,
		  :geometry => GeoRuby::SimpleFeatures::Point.from_coordinates([x,y]) }
	end

end #End of Twitterer Class