'''
A simple script to assign handles to the users
'''
require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'
require 'mongo_mapper'

require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'


#Static Setup
MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

Twitterer.where(:handle.in => ["",nil]).each_with_index do |user, i|
  handle = user.tweets.collect{|tweet| tweet["handle"]}.flatten.uniq.join(', ')
  user.handle = handle
  user.save

  if (i%100).zero?
    print "#{i}.."
  end
end