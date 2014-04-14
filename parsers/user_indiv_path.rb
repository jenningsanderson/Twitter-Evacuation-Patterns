'''
Purpose:
  Build a new collection with 1 document for each user that stores their tweets
  as Point collections based on the time: before, during, after storm.
'''

require 'mongo'
require 'json'
require 'time'

class IndivUserPath

  attr_reader :user

  def initialize(user_id)
    @user = {:id=>user_id,
             :handle=>[],
             :points => [],
             :path => {:type=>"Feature",
                       :geometry=>{
                          :type=>"LineString",
                          :coordinates=>[]
                      }},
             :type => "FeatureCollection",
             :tweet_count   => 0}
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

  #Iterate through a user's tweets, build two features
  def parse_tweets
    @tweets.each do |tweet|
      @user[:handle] << tweet["user"]["screen_name"]
      unless tweet["place"].nil?
        place = tweet["place"]["full_name"]
      else
        place = nil
      end

      @user[:points] << {:type=>"Feature",
                         :geometry=>{:type=>"Point",
                         :coordinates=>tweet["coordinates"]["coordinates"]},
                         :properties=>{:created_at=>tweet["created_at"],
                                       :text=>tweet["text"],
                                       :place=>tweet["place"]["full_name"]}}
      @user[:path][:geometry][:coordinates] << tweet["coordinates"]["coordinates"]
    end
  end

  # Perform any final checks... yes, this would be better as m/r, but it crashed...
  def finalize_user
    @user[:handle] = @user[:handle].uniq.join(',')
    @user[:path][:properties]={:tweet_count=>@user[:tweet_count],
                                :handle=>@user[:handle]}
    @user[:features] = [@user[:path]]+user[:points]
    @user.delete(:points)
    @user.delete(:path)
  end
end #class

if __FILE__ == $0
  limit = 1000000
  new_db = 'user_indiv_tweets'

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
    usertweets = IndivUserPath.new(user_id)
    if usertweets.get_user_tweets
      usertweets.parse_tweets
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
