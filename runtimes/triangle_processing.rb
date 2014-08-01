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

Twitterer.where( :triangle_area.gte => 100).limit(nil).each_with_index do |user, index|
  
  user.isoceles_ratio = user.before_during / user.during_after
  user.save

  if (index % 100).zero?
    print "."
  elsif (index%1001).zero?
    print index
  end

end #End the Search

