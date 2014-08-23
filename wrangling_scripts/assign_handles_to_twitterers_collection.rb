'''
A simple script to assign handles to the users
'''

require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'


#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

Twitterer.where(:handle => "").each_with_index do |user, i|
  handle = user.tweets.collect{|tweet| tweet["handle"]}.flatten.uniq.join(', ')
  user.handle = handle
  #puts handle
  #user.process_geometry
  user.save

  if (i%100).zero?
    print "#{i}.."
  end
end