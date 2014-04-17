'''
Purpose:
  Build a new collection with 1 document for each user that stores their tweets
  as Point collections.
'''

require 'mongo'
require 'json'
require 'time'

class IndivTwitterers

  attr_reader :user

  def initialize(user_id)
    @user = {:id          =>user_id,
             :handle      =>[],
             :features    =>[],
             :type        =>"FeatureCollection",
             :tweet_count => 0 }
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

      @user[:features]<<{:type        =>"Feature",
                         :geometry    =>{:type=>"Point",
                         :coordinates =>tweet["coordinates"]["coordinates"]},
                         :properties  =>{:created_at=>tweet["created_at"],
                                         :text=>tweet["text"],
                                         :place=>place}}
    end
  end

  #Perform any final operations
  def finalize_user
    @user[:handle] = @user[:handle].uniq.join(',')
  end
end #class

impact_hull = {
	"type" : "Polygon",
	"coordinates" : [
		[
			[
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
			]
		]
	]
}



#Calling this only for users that are in our collection!

if __FILE__ == $0
  limit = 1000000
  new_db = 'most_impacted_users'

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
  query = DB['userpaths'].find({geometry=>'$geoIntersects'=>{'$geometry'=>impact_hull}})

  distinct_users = query.first(limit)

  puts "Parsing #{distinct_users.count()}"

  #Parse each distinct user
  distinct_users.each_with_index do |user_id, i|
    usertweets = IndivTwitterers.new(user_id)
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
