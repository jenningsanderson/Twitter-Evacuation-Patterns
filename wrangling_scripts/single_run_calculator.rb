#
# A simple script that crawls the user Twitterer collection and can perform
# single calculations.  
#
# DO NOT SAVE TO THE TWITTERERS COLLECTION FROM THIS SCRIPT
#
require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'

require 'mongo_mapper'
require 'epic-geo'
require 'mongo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Static Setup
MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'


#Search the Twitterer collection
results = Twitterer.where(

#Put the filters here:
  :tweet_count.gte => 1

).limit(nil)

puts "Search returned #{results.count} results"

# counter = 0
tweet_sum = 0
second_sum = 0
results.each_with_index do |user, index|

  tweet_sum += user.tweet_count
  second_sum += user.tweets.length

  #=============== Show Status
  if (index % 100).zero?
    print "."
  elsif (index%1001).zero?
    print "(#{tweet_sum} | #{second_sum}/ #{index})"
  end
end #End the Search

puts "\n=========================\ntweet_count sum: #{tweet_sum}"
puts "\n=========================\ntweet array sum: #{second_sum}"
