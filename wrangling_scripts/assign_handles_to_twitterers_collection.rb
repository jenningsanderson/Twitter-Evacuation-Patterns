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

results = Twitterer.where(:handle.in => ["",nil]).sort(:tweet_count)

puts "Found #{results.count} users without handles"
results.each_with_index do |user, i|
	begin
		handle = user.tweets.collect{|tweet| tweet["handle"]}.flatten.uniq.join(', ')
		user.handle = handle
		user.save

		if (i%100).zero?
			print "#{i}.."
		end
	rescue => e 
		puts "Ahh!  An error occured"
		puts $!
		puts e.backtrace
		next
	end
end