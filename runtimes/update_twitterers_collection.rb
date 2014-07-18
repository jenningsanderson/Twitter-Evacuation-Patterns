'''
Scripts to run on an existing twitterers collection to perform calculations

'''

require 'mongo_mapper'

require_relative '../fileio/tweet_io'
require_relative '../models/twitterer'
require_relative '../models/tweet'


#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

Twitterer.all.each do |user|
  #puts user.id_str
  #handle = user.tweets.collect{|tweet| tweet["handle"]}.flatten.uniq.join(',')
  #puts handle
  #user.handle = handle
  user.process_geometry
  user.save
end
