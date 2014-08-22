#Sandbox 2 for running locally on servr

require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'
require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'

MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

results = Twitterer.where(
	:hazard_level_before => 10
).limit(1)

puts "Found #{results.count} results, now processing"

results.each_with_index do |user, index|

	puts user.handle

	user.new_location_calculation

	user.issue = 23

	#user.save

	puts "\n====================\n"

	
	if (index % 10).zero?
		print "."
	elsif (index%101).zero?
		print "#{index}"
	end
end