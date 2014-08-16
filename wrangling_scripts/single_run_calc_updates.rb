#
# A simple script that crawls the user Twitterer collection and can perform
# single updates
#
#

require 'mongo_mapper'
require 'epic-geo'
require 'mongo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

#Set up mongo to connect to another db too...
conn = Mongo::MongoClient.new('epic-analytics.cs.colorado.edu')
db = conn['sandygeo']
coll = db['edited_tweets']

#Define the timewindows to split the tweets into
sandy_dates = [
  Time.new(2012,10,20), #Start of dataset
  Time.new(2012,10,28), #Start of storm
  Time.new(2012,11,1),  #End of Storm
  Time.new(2012,11,9)   #End of Dataset
]

#These names correspond with the KML styles for coloring
time_frames = ["before", "during", "after"]


limit = nil

#Search the Twitterer collection
results = Twitterer.where(

#Put the filters here:
  :tweet_count.gte => 1,
  :tweet_count.lte => 100

).limit(limit)

puts "Search returned #{results.count} results"

counter = 0
results.each_with_index do |user, index|

  flagged = false

  this_users_tweets = coll.find({"user.id_str" => user.id_str}).to_a

  user.tweets.each do |embedded_tweet|
    if embedded_tweet.id_str.nil?
      flagged = true
      # puts "This Tweet: #{embedded_tweet.date} | #{embedded_tweet.text}"

      look_up = this_users_tweets.select{|tweet| (tweet["text"] == embedded_tweet.text and tweet["created_at"] == embedded_tweet.date)}[0]

      # look_up_text = look_up["text"]
      # look_up_date = look_up["created_at"]
      # puts "Look Tweet: #{look_up_date} | #{look_up_text}"

      embedded_tweet.id_str = look_up["id_str"]
    end
    user.save if flagged
  end


  #=============== Show Status
  if (index % 100).zero?
    print "."
  elsif (index%1001).zero?
    print "(#{counter} / #{index})"
  end

end #End the Search
