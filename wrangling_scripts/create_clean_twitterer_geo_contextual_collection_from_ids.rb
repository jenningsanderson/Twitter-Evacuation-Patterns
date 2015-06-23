#   This script is made to run on the server and will iterate through a list of handles
#  and collect the corresponding contextual streams. Given the tweet id, it will also
#  check to see if the tweet was collected in the keyword search, marking it at so.
#

#First, create the runtime
require_relative '../movement_derivation_controller.rb'

require 'modules/contextual_stream'

runner = TwitterMovementDerivation.new(environment: 'server')
context = ContextualStream::ContextualStreamRetriever.new({})

#Make another connection to Mongo for the keyword search (This one IS on the server)
conn = Mongo::MongoClient.new('epic-analytics.cs.colorado.edu')
db = conn['hurricane_sandy']
keyword_tweets = db['tweets']

#import the list of ids
File.readlines('datasets/ids_geo_ny_nj.txt').first(2).each do |line|
  handle = line.split(',')[0]
  puts handle

  #First, get the user_id
  context.set_file_path(handle)
  id_str = context.get_user_id_str(handle)

  user_tweets = []

  unless id_str.nil?
    keyword_tweet_ids = keyword_tweets.find({'user.id_str' => id_str},{fields: ['id_str']}).to_a.collect{|x| x["id_str"]}
    all_tweets = context.get_full_stream(geo_only=true)

    all_tweets.sort_by{|t| t[:Date]}.each do |t|
      this_tweet = Tweet.new(
          { "id_str" => t[:Id],
            "text"   => t[:Text],
            "user"   => {
              "id_str" => id_str,
              "screen_name" => t[:Handle]
            },
            "coordinates" => t[:Coordinates]
            "date"   => t[:Date]
          }
        )
      if keyword_tweet_ids.include? t[:Id]
        this_tweet.contextual = false
      else
        this_tweet.contextual = true
      end

      user_tweets << this_tweet
    end

    puts user_tweets

  else
    puts "ERROR! user: #{handle} --"
  end
end
