# Connects to the current SandyGeo Edited Tweets database and then creates the
# twitterers collection based on the users from these tweets.


require 'mongo_mapper'

require_relative '../fileio/tweet_io'
require_relative '../models/twitterer'
require_relative '../models/tweet'

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

limit = 10000000

puts "Running the User Import for #{limit} users"
sandy_tweets = SandyMongoClient.new(limit=limit)

existing_ids = Twitterer.distinct("id_str")

puts "There are #{existing_ids.length} distinct users in the collection already"

distinct_users = sandy_tweets.get_distinct_users

puts "There are #{distinct_users.length} in the entire tweet collection"

to_import = distinct_users - existing_ids

puts "There are #{to_import.length} user ids left to import"

puts "Iterating over the cursor and building more defined people objects"
to_import.each_with_index do |uid, index|

  this_user = Twitterer.create( {:id_str => uid} )

  sandy_tweets.get_user_tweets(uid).each do |tweet|
    this_user.tweets << Tweet.new( tweet )
  end

  if (index%10).zero?
    print "..#{index}"
  end

  this_user.save
end

puts "\n-----------\n"
