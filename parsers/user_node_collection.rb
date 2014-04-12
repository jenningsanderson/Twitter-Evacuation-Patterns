'''
Purpose:
  Build a new collection with 1 document for each user that stores their tweets
  as Point collections based on the time: before, during, after storm.
'''

require 'mongo'
require 'json'
require 'time'

class UserTweetsByTime

  @@storm_begin = Time.new(2012, 10, 22)
  @@storm_end   = Time.new(2012, 11, 1)

  attr_reader :user

  def initialize(user_id)
    @user = {:id=>user_id,
             :handle=>[],
             :type => "FeatureCollection",
             :features=> [],
             :handle        =>[],
             :tweet_count   => 0}
    ["before", "during", "after"].each do |time|
      instance_eval "@user[:#{time}_coords] = []"
      instance_eval "@user[:#{time}_properties] = []"
    end
  end

  #Retrieve User's tweets, in chronological order
  def get_user_tweets
    @tweets = COLL.find(
      selector = {"user.id" => @user[:id]},
      opts={ :sort=>["created_at", Mongo::ASCENDING],
             :fields=>["coordinates","user","text","created_at", "entities", "place"]
          })

    @user[:tweet_count] = @tweets.count
    @tweets.count > 1
  end

  #Iterate through a user's tweets, build the document based on time
  def parse_tweets
    @tweets.each do |tweet|
      @user[:handle] << tweet["user"]["screen_name"]
      @user[:tweet_count] += 1
      unless tweet["place"].nil?
        place = tweet["place"]["full_name"]
      else
        place = nil
      end

      #If before the storm, then build that feature collection
      if tweet["created_at"] < @@storm_begin

        @user[:before_coords] << tweet["coordinates"]["coordinates"]
        @user[:before_properties]  << {:text      =>tweet["text"],
                                       :created_at=>tweet["created_at"],
                                       :place     =>place}

      #Build during the storm collection
      elsif tweet["created_at"] < @@storm_end
        @user[:during_coords] << tweet["coordinates"]["coordinates"]
        @user[:during_properties]   << {:text      =>tweet["text"],
                                       :created_at=>tweet["created_at"],
                                       :place     =>place}

      #Build after the storm collection
      else
        @user[:after_coords] << tweet["coordinates"]["coordinates"]
        @user[:after_properties]   << {:text      =>tweet["text"],
                                       :created_at=>tweet["created_at"],
                                       :place     =>place}
      end
    end
  end

  def write_feature
    ["before", "during", "after"].each do |time|
      coords = instance_eval( "@user[:#{time}_coords]" )
      unless coords.empty?
        if coords.length > 1
          type = "MultiPoint"
        elsif
          coords.length == 1
          type = "Point"
          coords = coords[0]
        end
          @user[:features] << {:feature=>
            {:type        => type,
             :coordinates => coords},
             :properties  => instance_eval( "@user[:#{time}_properties]" )
           }
      end

       #Remove the previous props
       instance_eval( "@user.delete :#{time}_coords" )
       instance_eval( "@user.delete :#{time}_properties" )
    end
  end

  # Perform any final checks... yes, this would be better as m/r, but it crashed...
  def finalize_user
    @user[:handle] = @user[:handle].uniq.join(',')
  end
end #class

if __FILE__ == $0
  limit = 1000000
  new_db = 'usertweets'

  limit_string = ARGV.join.scan(/limit=\d+/i).first

  unless limit_string.nil?
    limit=limit_string.gsub!('limit=','').to_i
  end

  puts "Connecting to Mongo"
  mongo_conn = Mongo::MongoClient.new
  DB = mongo_conn['sandygeo']
  COLL = DB['edited_tweets']

  puts "Dropping previous collection...",
  DB[new_db].drop()
  puts "done"

  puts "Calling the User Tweet Parser with:"
  puts "limit: #{limit}"

  puts "Getting distinct Users"
  distinct_users = COLL.distinct("user.id").first(limit)

  #Parse each distinct user
  distinct_users.each_with_index do |user_id, i|
    usertweets = UserTweetsByTime.new(user_id)
    if usertweets.get_user_tweets
      usertweets.parse_tweets
      usertweets.write_feature
      usertweets.finalize_user
      DB[new_db].insert(usertweets.user)
    else
      puts "#{user_id} had only 1 tweet"
    end

    #Show status
    if (i%100).zero?
      puts "Parsed #{i} users"
    end
  end

  puts "Adding indexes"
  puts DB[new_db].create_index({"id" => 1})
  puts DB[new_db].create_index({"tweet_count" => 1})
  #puts DB[new_db].create_index({"features" => "2dsphere"})
end
