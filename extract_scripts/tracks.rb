require 'rgeo-shapefile'
require 'geo_ruby'
require 'geo_ruby/shp'
require 'mongo'
require 'pp'
require 'time'

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
    start_time = Time.now
    puts "Started: #{start_time}"

    #Make 2 new shapefiles: 1 for lines, 1 for tweets
    line_shape = Tweet_Shapefile.new("user_tracks_lines_#{lim}")
    line_shape.create_line_shapefile

    tweet_shape = Tweet_Shapefile.new("user_tracks_tweets_#{lim}")
    tweet_shape.create_point_shapefile

    #Open connection to Mongo
    conn = SandyMongoClient.new

    conn.get_distinct_users.first(lim).each_with_index do |user, i|
      points = []
      tweet_data = {:handle=>[] }

      tweets = conn.get_user_tweets(user)

      unless tweets.count <2
        tweets.each do |tweet|
          # Make point from tweet and add to array
          points << GeoRuby::SimpleFeatures::Point.from_x_y(
              tweet["geo"]["coordinates"][1],
              tweet["geo"]["coordinates"][0])

          tweet_data[:tweets] = points.count

          unless tweet_data[:handle].include? tweet["user"]["screen_name"]
            tweet_data[:handle] << tweet["user"]["screen_name"]
          end

          if tweet["entities"]["hashtags"].count > 0
            hashtags = tweet["entities"]["hashtags"].collect{ |x| x["text"]}.join(', ')
          else
            hashtags = "None"
          end

          if tweet["entities"]["urls"].count > 0
            urls = tweet["entities"]["urls"].collect{ |x| x["expanded_url"]}.join(', ')
          else
            urls = "None"
          end

          if tweet.has_key? ["place"]
            loc = tweet["place"]["full_name"]
          else
            loc = "None"
          end

          #Add the tweet to the tweet file
          tweet_shape.add_point({
            :coords=>tweet["geo"]["coordinates"],
            :text  =>tweet["text"],
            :user_name => tweet["user"]["screen_name"],
            :time => tweet["created_at"],
            :hashtags => hashtags,
            :location => loc,
            :urls => urls})
          end
          line_shape.add_line(points, tweet_data)
        end
        if i%100==0
          puts "Completed #{i} Twitter users."
        elsif i%501==0
          rate = i/(Time.now - start_time)
          minutes = ( (lim-i)/rate ) / 60
          puts "Completed #{i} users at #{'%.02f' % rate} Users/second, est #{'%.02f' % minutes} minutes remaining"
        end
      end #end user iterator

    tweet_shape.close()
    line_shape.close()
  else # end tracks
    puts "Please specify an argument, such as -tracks"
  end
end #end runtime
