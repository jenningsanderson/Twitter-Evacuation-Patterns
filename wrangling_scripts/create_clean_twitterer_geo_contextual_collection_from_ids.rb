#   This script is made to run on the server and will iterate through a list of handles
#  and collect the corresponding contextual streams. Given the tweet id, it will also
#  check to see if the tweet was collected in the keyword search, marking it at so.
#

#First, create the runtime
require_relative '../movement_derivation_controller.rb'

runner = TwitterMovementDerivation.new(environment: 'server', database: 'sandygeo')
context = ContextualStream::ContextualStreamRetriever.new({
  # root_path: '/data/CHIME/geo_user_collection/'
  })

#Make another connection to Mongo for the keyword search (This one IS on the server)
conn = Mongo::MongoClient.new('epic-analytics.cs.colorado.edu')
db = conn['hurricane_sandy']
keyword_tweets = db['tweets']

#Log the errors
errors = File.open('error_handles.txt','wb')

#import the list of ids
File.readlines('datasets/ids_geo_ny_nj.txt').each_with_index do |line, index|
  handle = line.split(',')[0]
  puts handle, index

  #First, get the user_id
  context.set_file_path(handle)
  id_str = context.get_user_id_str
  user_join_date = context.get_user_join_date

  user_tweets = []

  unless id_str.nil?
    keyword_tweet_ids = keyword_tweets.find({'user.id_str' => id_str},{fields: ['id_str']}).to_a.collect{|x| x["id_str"]}
    all_tweets = context.get_full_stream(geo_only=true)

    all_tweets.sort_by{|t| t[:Date]}.each do |t|
      contextual = true
      if keyword_tweet_ids.include? t[:Id]
        contextual = false
      end

      this_tweet = Tweet.new(
            id_str: t[:Id],
            text:   t[:Text],
            user:   id_str,
            handle: t[:handle],
            coordinates: t[:Coordinates],
            date:   t[:Date],
            contextual: contextual
        )
      user_tweets << this_tweet
    end

    this_user = Twitterer.create(
      id_str: id_str,
      handle: handle,
      account_created: user_join_date,
    )

    this_user.tweets = user_tweets
    this_user.save!

  else
    puts "ERROR! user: #{handle} --"
    errors.write(handle + "\n")
  end
end

errors.close()