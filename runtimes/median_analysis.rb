'''
This script looks to build user objects for easy processing,
next, it should write this format back to Mongo
'''

require 'mongo_mapper'

require_relative '../fileio/tweet_io'
require_relative '../models/twitterer'
require_relative '../models/tweet'


#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

# puts "Running the median analysis"
# sandy_tweets = SandyMongoClient.new(limit=10)
#
# puts "Iterating over the cursor and building more defined people objects"
# sandy_tweets.get_distinct_users.each do |uid|
#
#   this_user = Twitterer.create( {:id_str => uid} )
#
#   sandy_tweets.get_user_tweets(uid).each do |tweet|
#     this_user.tweets << Tweet.new( tweet )
#   end
#
#   this_user.save
# end
#
# test_user = Twitterer.first
#
# puts "-----------\n"


Twitterer.where( :tweet_count.lte => 7 ).each do |user|
  puts "User #{user.id_str} has #{user.tweets.count} tweets"
  puts user.full_user_path.to_json
  #puts user.individual_points.to_json
  #puts user.individual_tweets.to_json
  puts user.full_median_point.to_json
end
