'''
A Twitterer model that works with active model and MongoMapper to save the objects
to Mongo.
'''

require 'mongo_mapper'
require 'active_model'
require 'rgeo'
require 'georuby'

#Load the geoprocessing algorithms
require_relative '../processing/geoprocessing'

class Twitterer

	@@tweet_factory = RGeo::Geographic.simple_mercator_factory

	attr_reader :points

	include MongoMapper::Document

	key :id_str, 			String, :required => true, :unique => true
	key :handle, 			String
	key :tweet_count, Integer

	#Sandy Evacuation Specific variables
	key :before, 			Array
	key :during, 			Array
	key :after, 			Array

	many :tweets

	#Callback functions
	before_save { self.tweet_count = tweets.count }


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
		median_point = find_median_point tweets.collect{|tweet| tweet.coordinates["coordinates"]}
		return {:type => "Point", :coordinates => median_point}
	end

	def process_geometry
		@points = tweets.collect do |tweet|
			@@tweet_factory.point( tweet.coordinates["coordinates"][0], tweet.coordinates["coordinates"][1] )
		end
	end

	def user_path
		@userpath = @@tweet_factory.line_string(@points)
	end

	def userpath_as_epic_kml
		linestring = GeoRuby::SimpleFeatures::LineString.from_coordinates( tweets.collect{|tweet| tweet.coordinates["coordinates"]} )
		{:name 			=> handle,
		 :geometry => linestring,
		}
	end

	def point_as_epic_kml(name, x, y, style=nil)
		{ :name => name,
			:style => style,
		  :geometry => GeoRuby::SimpleFeatures::Point.from_coordinates([x,y]) }
	end

	def user_points
		@@tweet_factory.multi_point(@points)
	end

	#The type is either 'before, during, or after'
	#coords is an array (lon, lat)
	def set_poi(type, coords)
		instance_eval "@#{type} = #{coords}"
	end

	def build_evac_triangle()
		unless @before.nil? or @during.nil? or @after.nil?
			triangle_points = [ @@tweet_factory.point(@before[0], @before[1]),
													@@tweet_factory.point(@during[0], @during[1]),
													@@tweet_factory.point(@after[0],  @after[1]),
													@@tweet_factory.point(@before[0], @before[1])]

			evac_triangle = @@tweet_factory.polygon(@@tweet_factory.linear_ring(triangle_points))

			puts evac_triangle
			puts evac_triangle.area
		end
	end

end
