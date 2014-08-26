#
# New Movement Calculation for updated users.
#

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
  :unclassified_percentage => nil

  ).limit(nil).sort(:tweet_count)

puts "Found #{results.count} results..."
evac_count = 0

results.each_with_index do |user, index|
  puts "User: #{user.handle}..."

  user.new_location_calculation

  user.issue = 500

  user.save #Write the user back to the collection

  if (index % 10).zero?
    print "."
  elsif (index%101).zero?
    print "#{index}"
  end
end