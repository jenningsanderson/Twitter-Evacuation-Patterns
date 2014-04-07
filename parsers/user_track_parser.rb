'''
1. Get distinct users

2. Iterate through distinct users, grab tweets (sort by date)

3. Build user track geo object

4. Save it back to Mongo as well?

5. Interested fields: time, screen_name, text
'''

require 'mongo'
require 'json'

class TwittererPath
  attr_reader :user_id, :screen_name, :user

  def initialize(user_id)
    @user = {:id=>user_id,
             :geometry=> {:type=>"LineString", :coordinates=>[]},
             :handle =>[],
             :tweets =>[]
            }
  end

  def get_user_tweets
    @tweets = COLL.find(
      selector = {"user.id" => @user[:id]},
      opts={ :sort=>["created_at", Mongo::ASCENDING],
             :fields=>["coordinates","user","text","created_at", "entities", "place"]
          })
    @tweets.count > 1
  end

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

  def finalize_user
    @user[:handle] = @user[:handle].uniq.join(',')
    case @tweets.count
    when 1..20
      DB['userpath_lt20'].insert(@user)
    when 20..50
      DB['userpath_20_50'].insert(@user)
    when 50..100
      DB['userpath_50_100'].insert(@user)
    when 100..200
      DB['userpath_100_200'].insert(@user)
    else
      DB['userpath_gt200'].insert(@user)
    end
  end
end #class

if __FILE__ == $0

  limit = 1000000

  limit_string = ARGV.join.scan(/limit=\d+/i).first
  unless limit_string.nil?
    limit=limit_string.gsub!('limit=','').to_i
  end

  puts "Calling the User Track Parser with:"
  puts "limit: #{limit}"

  puts "Connecting to Mongo"
  mongo_conn = Mongo::MongoClient.new
  DB = mongo_conn['sandygeo']
  COLL = DB['edited_tweets']

  puts "Getting distinct Users"
  distinct_users = COLL.distinct("user.id").first(limit)

  #Parse each distinct user
  distinct_users.each_with_index do |user_id, i|
    puts user_id
    userpath = TwittererPath.new(user_id)
    if userpath.get_user_tweets
      userpath.parse_tweets
      userpath.finalize_user
    else
      puts "#{user_id} had only 1 tweet"
    end

    #Show status
    if (i%100).zero?
      puts "Parsed #{i} users"
    end
  end
end
