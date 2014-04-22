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

  #Iterate through a user's tweets
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
	"type" => "Polygon",
	"coordinates" => [
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

coastal_users = { "type"=> "Polygon", "coordinates" =>[ [ [ -70.886659957482877, 42.359853818162861 ], [ -70.180999481201539, 42.099245295479847 ], [ -69.846411273526599, 42.006520450039893 ], [ -69.839280880606822, 41.196075968798034 ], [ -71.236837680145271, 41.120918187558935 ], [ -73.950201181853103, 40.356056261259027 ], [ -74.088994411614536, 39.363064600331889 ],
  [ -74.851946336695889, 38.469874944021875 ], [ -75.707593356027019, 36.512557563897516 ], [ -75.294030629733683, 35.584403839857629 ], [ -75.486551209508107, 35.078317292355578 ], [ -76.598892334474087, 34.345657101958196 ], [ -77.262018774030778, 34.633633064268381 ], [ -77.283409950048636, 34.862126549911807 ], [ -76.570370767729614, 35.305575492982868 ],
  [ -76.228111959668198, 35.665546666173249 ], [ -76.434893322540717, 36.323207464839605 ], [ -76.827064873912747, 37.208559779572894 ], [ -77.525843272585391, 38.346952395379624 ], [ -76.934020751260604, 39.747894282972297 ], [ -75.32968258884965, 40.700605501676776 ], [ -74.21734146388367, 41.517204065640087 ], [ -72.784132706325849, 41.964119364899787 ],
  [ -70.886659957482877, 42.359853818162861 ] ] ] }


#Calling this only for users that are in our collection!

if __FILE__ == $0
  limit = 1000000
  new_db = 'coastal_users'

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
  query = DB['userpaths'].find({'geometry'=>{'$geoIntersects'=>{'$geometry'=>coastal_users}}},{:fields=>['id']})

  distinct_users = query.first(limit).collect{|x| x["id"]}

  puts "Parsing #{distinct_users.length} distinct users"

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
