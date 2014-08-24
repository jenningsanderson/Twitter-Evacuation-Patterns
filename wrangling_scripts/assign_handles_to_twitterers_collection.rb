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
	handles = []
	begin
		user.tweets.each do |tweet|
			unless handles.include? tweet.handle
				handles << tweet.handle
			end
		end
		
		user.handle = handles.uniq.join(', ')
		#user.save

		puts user.handle

		if (i%100).zero?
			print "#{i}.."
		end
	rescue => e 
		puts "Ahh!  An error occured with user: #{user.handle}"
		puts $!
		puts e.backtrace
		next
	end
end