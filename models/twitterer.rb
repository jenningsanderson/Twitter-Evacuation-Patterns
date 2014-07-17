'''
A Twitterer model that works with active models
'''

require 'mongo_mapper'
require 'active_model'

#Load the geoprocessing algorithms
require_relative '../processing/geoprocessing'

class Twitterer
	include MongoMapper::Document

	key :id_str, 			String, :required => true, :unique => true
	key :handle, 			String
	key :tweet_count, Integer

	many :tweets

	#Callback functions
	before_save {self.tweet_count = tweets.count}


	#Returns a geojson MultiPoint object with each tweet as a point
	def individual_points
		points = tweets.collect{ |tweet| tweet.coordinates["coordinates"]}
		return {:type => "MultiPoint", :coordinates => points}
	end

	#Return a geojson Feature Collection of Individual Tweets
	def individual_tweets
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
	def full_user_path
		points = tweets.collect{ |tweet| tweet.coordinates["coordinates"]}
		return {:type => "LineString", :coordinates => points}
	end

	def full_median_point
		median_point = find_median_point tweets.collect{|tweet| tweet.coordinates["coordinates"]}
		return {:type => "Point", :coordinates => median_point}
	end

end
