'''
Purpose:
  Build a new collection with 1 document for each user that stores all tweets
  with useful information about the user (tweets, times, etc).

Runtime:
  ~20 minutes for 50k users and 3.8 million tweets
'''

require 'mongo'
require 'json'

class TwittererPath
  attr_reader :user_id, :screen_name, :user

  def initialize(user_id)
    @user = {:id=>user_id,
             :geometry=> {:type=>"LineString", :coordinates=>[]},
             :type => "Feature",
             :handle =>[],
             :tweets =>[],
             :tweet_count => 0}
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

  #Iterate through a user's tweets, build the document
  def parse_tweets
    @tweets.each do |tweet|
      @user[:handle] << tweet["user"]["screen_name"]
      @user[:geometry][:coordinates] << tweet["coordinates"]["coordinates"]
      @user[:tweets] << {:created_at=>tweet["created_at"],
                         :text => tweet["text"],
                         :entities=>tweet["entities"],
                         :place=>tweet["place"]}
    end
  end

  # Perform any final checks... yes, this would be better as m/r, but it crashed...
  def finalize_user
    @user[:handle] = @user[:handle].uniq.join(',')
  end
end #class

if __FILE__ == $0
  limit = 1000000
  new_db = 'userpaths'

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

  puts "Calling the User Track Parser with:"
  puts "limit: #{limit}"

  puts "Getting distinct Users"
  distinct_users = COLL.distinct("user.id").first(limit)

  #Parse each distinct user
  distinct_users.each_with_index do |user_id, i|
    userpath = TwittererPath.new(user_id)
    if userpath.get_user_tweets
      userpath.parse_tweets
      userpath.finalize_user
      DB[new_db].insert(userpath.user)
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
  puts DB[new_db].create_index({"coordinates" => "2dsphere"})
end
