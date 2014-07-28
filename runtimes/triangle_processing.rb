#
# Triangle Processing
#
# Run calculations on all of the triangles
#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

#Define the timewindows to split the tweets into
sandy_dates = [
  Time.new(2012,10,20), #Start of dataset
  Time.new(2012,10,28), #Start of storm
  Time.new(2012,11,1),  #End of Storm
  Time.new(2012,11,9)   #End of Dataset
]

#These names correspond with the KML styles for coloring
time_frames = ["before", "during", "after"]

#Search the Twitterer collection
counter = 0
Twitterer.where( :triangle_area.gte => 100).limit(10).each_with_index do |user, index|
  print "Beginning #{user.handle}: "

  #Must use proper error handling because issues have been known to arise
  begin

    user.



  rescue => e
    
  end #End the error handling

  if user.issue.zero?
      counter += 1
      print "..Success"
    else
      print "..F"
    end

  user.save
  puts ""

  if (index % 10).zero?
    puts "\t Status: #{index} processed, #{counter} were successful (#{counter.to_f/(index+1)})"
  end

end #End the Search

