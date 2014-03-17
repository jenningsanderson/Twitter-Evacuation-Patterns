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

    #Make 2 new shapefiles: 1 for lines, 1 for tweets
    line_shape = Tweet_Shapefile.new("~/sandy/lines_user_count#{lim}")
    line_shape.create_line_shapefile

    tweet_shape = Tweet_Shapefile.new("~/sandy/tweets_user_count#{lim}")
    tweet_shape.create_point_shapefile

    #Get the tweets I want, pass the limit
    conn = SandyMongoClient.new(limit=lim)
    tweets = conn.get_all()

    # Iterate through the users, getting their streams
    tweets.to_a.uniq.each_with_index do |tweet, i|
      user = tweet["user"]["id_str"]
      points = []
      tweet_data = {:handle=>[] }

      conn.get_user_tweets(user).each do |tweet|

        # Make point from tweet and add to array
        points << line_shape.make_point_from_tweet(tweet)

        unless tweet_data[:handle].include? tweet["user"]["screen_name"]
          tweet_data[:handle] << tweet["user"]["screen_name"]
        end

        #Add the tweet to the tweet file
        tweet_shape.add_point({
          :coords=>tweet["geo"]["coordinates"],
          :text  =>tweet["text"],
          :user_name => tweet["user"]["screen_name"],
          :time => tweet["created_at"]})

        if i%10 ==0
          puts "Completed #{i} Twitter users."
        end
      end
      unless points.length == 1
        line_shape.add_line(points, tweet_data)
      end
    end #end user iterator

  #  tweet_shape.close()
  #  line_shape.close()
  else # end tracks
    puts "Please specify an argument, such as -tracks"
  end

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
