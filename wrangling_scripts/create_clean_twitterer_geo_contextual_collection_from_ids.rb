#   This script is made to run on the server and will iterate through a list of handles
#  and collect the corresponding contextual streams. Given the tweet id, it will also
#  check to see if the tweet was collected in the keyword search, marking it at so.
#

#First, create the runtime
require_relative '../movement_derivation_controller.rb'

require 'modules/contextual_stream'

runner = TwitterMovementDerivation.new(environment: 'local')
context = ContextualStream::ContextualStreamRetriever.new({})

#Make another connection to Mongo for the keyword search (This one IS on the server)
conn = Mongo::MongoClient.new('epic-analytics.cs.colorado.edu')
db = conn['hurricane_sandy']
keyword_tweets = db['tweets']

#import the list of ids
File.readlines('datasets/ids_geo_ny_nj.txt').first(10).each do |line|
  handle = line.split(',')[0]

  #First, get the user_id
  context.set_file_path(handle)

  id_str = context.get_user_id_str(handle)

  context.get_full_stream(geo_only=true)

  puts handle
  keyword_tweet_ids = keyword_tweets.find({'user.id_str' => id_str})
  puts keyword_tweet_ids.count()

end
