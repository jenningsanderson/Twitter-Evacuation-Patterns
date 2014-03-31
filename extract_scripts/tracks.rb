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

    #Make 2 new shapefiles and open them both for writing...
    line_shape = Tweet_Shapefile.new("user_tracksEdited_lines_#{lim}")
    line_shape.create_line_shapefile
    line_shape.shapefile.transaction do |tracks_tr|

      tweet_shape = Tweet_Shapefile.new("user_tracksEdited_tweets_#{lim}")
      tweet_shape.create_point_shapefile
      tweet_shape.shapefile.transaction do |tweets_tr|

        #Open connection to Mongo, iterate over distinct #lim users
        conn = SandyMongoClient.new
        conn.get_distinct_users.first(lim).each_with_index do |user, i|

          tweet_data = {:handle=>[], :count=>0, :points=>[]}
          tweets = conn.get_user_tweets(user)
          tweets.each do |tweet|

            point = GeoRuby::SimpleFeatures::Point.from_x_y(
              tweet["geo"]["coordinates"][0],
              tweet["geo"]["coordinates"][1]) #This should be working ... why isn't it?

            tweet_data[:points] << point

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
            tweets_tr.add(GeoRuby::Shp4r::ShpRecord.new(point,
               :coords.to_s=>tweet["geo"]["coordinates"],
               :text.to_s  =>tweet["text"],
               :handle.to_s => tweet["user"]["screen_name"],
               :time.to_s => tweet["created_at"],
               :hashtags.to_s => hashtags,
               :loc.to_s => loc,
               :urls.to_s => urls))
            tweet_data[:count] += 1
          end #End user's tweets iteration
          tweets.close()

          tracks_tr.add(GeoRuby::Shp4r::ShpRecord.new(
            GeoRuby::SimpleFeatures::LineString.from_points(tweet_data[:points]),
            "Handle"=>tweet_data[:handle].join(','),
            "Tweets"=>tweet_data[:count]))
          tweet_data = nil
          if i%100==0
            puts "Completed #{i} Twitter users."
          elsif i%501==0
            rate = i/(Time.now() - start_time) #Tweets processed / seconds elapsed
            mins = (lim-i) / rate / 60         #minutes left = tweets left * seconds/tweet / 60
            hours = mins / 60
            puts "Status: #{'%.2f' % rate} Tweets/Second. #{'%.2f' % mins} minutes left or #{'%.2f' % hours} hours."
          end
        end #end distinct user iteration
      end #End tweet transaction
    end #End the line transaction
  end
end #end runtime
