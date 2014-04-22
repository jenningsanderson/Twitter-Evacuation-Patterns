require 'geo_ruby'
require 'mongo'
require 'time'

require '../tweet_io'    #=> Interface with Mongo

if __FILE__ == $0

  lim = ARGV[1].to_i

  puts "Calling Mongo, limit: #{lim}"
  start_time = Time.now
  puts "Started: #{start_time}"

  #Open connection to Mongo
  conn = SandyMongoClient.new
  bounding_box = [[[-81,36], [-81,45], [-68,45], [-68,36], [-81,36]]] #This is a Polygon

  bounding_box_geometry = {"type" : "Polygon",
                           "coordinates" : [ [ [
                      				-76.7672678371136,
                      				34.0426832743069
                      			],
                      			[
                      				-84.61526198160283,
                      				35.14964571764644
                      			],
                      			[
                      				-83.8587223039507,
                      				37.39249536202459
                      			],
                      			[
                      				-83.85794770664033,
                      				37.394215809178455
                      			],
                      			[
                      				-82.6119289400604,
                      				41.58945822578481
                      			],
                      			[
                      				-81.00583199495921,
                      				42.110938435158324
                      			],
                      			[
                      				-78.42313408642725,
                      				42.746126293069146
                      			],
                      			[
                      				-71.16885681969873,
                      				43.060666226440595
                      			],
                      			[
                      				-69.0075767753205,
                      				41.766901910412685
                      			],
                      			[
                      				-75.18819916854993,
                      				34.99048811994315
                      			],
                      			[
                      				-76.7672678371136,
                      				34.0426832743069
                      			] ] ] }

  #Open connection to Mongo, iterate over distinct #lim users
  conn.get_users_intersecting_bbox_from_tracks(bounding_box).first(lim).each_with_index do |user, i|

      tweet_data = {:handle=>[], :id_str=>user, :count=>0, :points=>[]}

      #Get user's tweets
      tweets = conn.get_user_tweets(user)
      unless tweets.count < 2 #Only get users that had more than one tweet.
        tweets.each do |tweet|

          point = GeoRuby::SimpleFeatures::Point.from_x_y(
            tweet["coordinates"]["coordinates"][0],
            tweet["coordinates"]["coordinates"][1])

          tweet_data[:points] << point

          #If they changed their username, record it
          unless tweet_data[:handle].include? tweet["user"]["screen_name"]
            tweet_data[:handle] << tweet["user"]["screen_name"]
          end

          #Pull out hashtags
          if tweet["entities"]["hashtags"].count > 0
            hashtags = tweet["entities"]["hashtags"].collect{ |x| x["text"]}.join(', ')
          else
            hashtags = "None"
          end

          #Pull out URLs
          if tweet["entities"]["urls"].count > 0
            urls = tweet["entities"]["urls"].collect{ |x| x["expanded_url"]}.join(', ')
          else
            urls = "None"
          end

          #See if Twitter already found a place
          unless tweet["place"].nil?
            loc = tweet["place"]["full_name"]
          else
            loc = "None"
          end

          #Add the tweet to the tweet file
          tweets_tr.add(GeoRuby::Shp4r::ShpRecord.new(point,
             :coords.to_s=>tweet["coordinates"]["coordinates"],
             :text.to_s  =>tweet["text"],
             :handle.to_s => tweet["user"]["screen_name"],
             :time.to_s => tweet["created_at"],
             :hashtags.to_s => hashtags,
             :loc.to_s => loc,
             :urls.to_s => urls,
             :ID_STR.to_s =>tweet["user"]["id_str"]))
          tweet_data[:count] += 1
        end #End unless
      end #End user's tweets iteration
      tweets.close()

      #Add the points as a linestring to the line shapefile.
      line_string = GeoRuby::SimpleFeatures::LineString.from_points(tweet_data[:points])

      tracks_tr.add(GeoRuby::Shp4r::ShpRecord.new(line_string,
        "Handle"=>tweet_data[:handle].join(','),
        "Tweets"=>tweet_data[:count],
        "ID_STR"=>tweet_data[:id_str]))

      tweet_data = nil #Save memory?
      if i%100==0
        puts "Completed #{i} Twitter users."
      elsif i%501==0
        rate = i/(Time.now() - start_time) #Tweets processed / seconds elapsed
        mins = (lim-i) / rate / 60         #minutes left = tweets left * seconds/tweet / 60
        hours = mins / 60
        puts "Status: #{'%.2f' % rate} Tweets/Second. #{'%.2f' % mins} minutes left or #{'%.2f' % hours} hours."
      end #End status update
    end #end distinct user iteration
    end #end tweet shapefile
    end #end lineshapefile
  end #end runtime options
end #end runtime
