'''
Initially developed for testing

Connects to the current SandyGeo Edited Tweets database and then creates the twitterers collection based on the users from these tweets.
'''

require 'mongo_mapper'

require_relative '../fileio/tweet_io'
require_relative '../models/twitterer'
require_relative '../models/tweet'

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

limit = 250

puts "Running the User Import for #{limit} users"
sandy_tweets = SandyMongoClient.new(limit=limit)

puts "Iterating over the cursor and building more defined people objects"
sandy_tweets.get_distinct_users.each_with_index do |uid, index|

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
