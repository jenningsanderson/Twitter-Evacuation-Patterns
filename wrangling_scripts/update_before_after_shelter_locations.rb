#
# Updating Before & After Shelter locations & GeoCoordinates
#

require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Static Setup
MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'


results = Twitterer.where( 
	
	:path_affected => true,
	:unclassifiable.ne => true,
	:issue => 1000,

).limit(nil).sort(:tweet_count)

puts "Found #{results.count} users"

results.each_with_index do |user, index|

	user.before_home_cluster = find_before_home(user.clusters_per_day)
	user.cluster_locations[:before_home] = user.cluster_locations[user.before_home_cluster]
	
	user.after_home_cluster  = find_after_home(user.clusters_per_day)
	user.cluster_locations[:after_home]  = user.cluster_locations[user.after_home_cluster]
	
	user.issue = 1200

	user.save

	if (index % 100).zero?
	    print "."
	elsif (index%1001).zero?
	    print "#{index}"
	end

	puts "==================\n\n"

end