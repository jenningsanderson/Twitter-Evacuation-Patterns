require 'rgeo-shapefile'
require 'geo_ruby'
require 'geo_ruby/shp'
require 'mongo'
require 'pp'

require '../tweet_shape' #=> Get the shape file writer
require '../tweet_io'    #=> Interface with Mongo


#Make a shapefile
tweet_shape = Tweet_Shapefile.new('line_test')
tweet_shape.create_point_shapefile

tweets = SandyMongoClient.new #Initiate client

tweets.query = {"text"=>/SATstudyTime/} #Set the particular query

gen = tweets.get_tweets_for_plot #Get the tweets

gen.each do |tweet|
  tweet_shape.add_point(tweet)
end

tweet_shape.close
