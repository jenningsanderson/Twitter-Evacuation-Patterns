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
	:issue.gte => 50,
	:unclassifiable => nil,
	:shelter_in_place => true,
	:shelter_in_place_location => nil
	
)

puts "Found #{results.count} results, now processing"

results.each_with_index do |user, index|

	puts user.handle

	unless user.cluster_locations[:before_home].nil? and user.cluster_locations[:after_home].nil?
		if user.cluster_locations[:before_home] == user.cluster_locations[:after_home]
	 		if user.during_storm_movement.empty?
	 			user.shelter_in_place_location = user.cluster_locations[:before_home]
	 			user.save
			end
		end
	end


	puts "\n====================\n"

	
	if (index % 10).zero?
		print "."
	elsif (index%101).zero?
		print "#{index}"
	end
end