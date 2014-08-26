#
# Local Testing
#
# Used for running an update locally on the Server.
#
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
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

results = Twitterer.where( 
	
	:path_affected => true,
	:percentage_unclassified.gte => 0
	:unclassifiable => nil

).limit(nil).each do |user|

results.each_with_index do |user, index|

	user.unclassifiable = false
	user.save

	if (index % 10).zero?
		print "."
	elsif (index%101).zero?
		print "#{index}"
	end

end
