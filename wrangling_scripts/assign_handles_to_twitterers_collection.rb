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
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

results = Twitterer.where(:handle => nil)

puts "Found #{results.count} users without handles"

results.each_with_index do |user, i|
	puts user.id_str
	handles = []
	begin
		handles = user.tweets.collect{|tweet| tweet.handle}.uniq
		user.handle = handles.join(', ')
		user.save

		if (i%10).zero?
			print "#{i}.."
		end
	rescue => e 
		puts "Ahh!  An error occured with user: #{user.id_str}"
		puts $!
		puts e.backtrace
	end
end