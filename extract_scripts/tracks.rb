require 'rgeo-shapefile'
require 'geo_ruby'
require 'geo_ruby/shp'
require 'mongo'
require 'pp'

require '../tweet_shape' #=> Get the shape file writer
require '../tweet_io'    #=> Interface with Mongo


if __FILE__ == $0
  if ARGV[0] == '-tracks'
    #Get limit if one is set
    lim = 10
    if ARGV[1]
      lim = ARGV[1].to_i
    end
    puts "Calling Mongo, limit: #{lim}"

    #Make a new shapefile for writing, make line
    tweet_shape = Tweet_Shapefile.new('line_test')
    tweet_shape.create_line_shapefile

    #Get the tweets I want:
    conn = SandyMongoClient.new(limit=lim)
    tweets = conn.get_all()

    # Iterate through the tweets, go back and call each user found in the above
    # set of tweets
    tweets.each do |tweet|
      user = tweet["user"]["id_str"] # individual users for this test

      #TODO: Add a linestring to the shapefile with good info...
      #tweet_shape.add_line(user)

      points = []

      conn.get_user_tweets(user).each do |user_tweet|
        # Make point from tweet and add to array
        points << tweet_shape.make_point_from_tweet(user_tweet)

        # Create linestring from array of points
        tweet_shape.add_line(points)
      end
      puts points.inspect
      puts "--------------"
    end #end user iterator
  end # end tracks
end #end runtime


# #Make a shapefile
# tweet_shape = Tweet_Shapefile.new('line_test')
# tweet_shape.create_point_shapefile
#
# gen = tweets.get_tweets_for_plot #Get the tweets
#
# gen.each do |tweet|
#   tweet_shape.add_point(tweet)
# end
#
# tweet_shape.close
