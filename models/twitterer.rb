'''
A Twitterer model that works with active model and MongoMapper to save the objects
to Mongo.
'''

require 'mongo_mapper'
require 'active_model'
require 'rgeo'

#Load the geoprocessing algorithms
require_relative '../processing/geoprocessing'

class Twitterer

	@@tweet_factory = RGeo::Geographic.simple_mercator_factory

	include MongoMapper::Document

	key :id_str, 			String, :required => true, :unique => true
	key :handle, 			String
	key :tweet_count, Integer

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

	def user_points
		@@tweet_factory.multi_point(@points)
	end

end
