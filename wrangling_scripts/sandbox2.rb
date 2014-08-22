require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'

MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

results = Twitterer.where(
	:issue => nil
)

puts "Found #{results.count} results, now processing"

results.each_with_index do |user, index|

	user.issue = 0

	user.save

	if (index % 10).zero?
		print "."
	elsif (index%101).zero?
		print "#{index}"
	end
end