# KML Export
#
# Write a KML file of Users and their tweets from the Twitterers collection
#

require 'mongo_mapper'
require 'epic-geo'
require 'rsruby'

require_relative '../models/twitterer'
require_relative '../models/tweet'


#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

sandy_dates = [
  Time.new(2012,10,19), #Start of dataset
  Time.new(2012,10,28), #Start of storm
  Time.new(2012,11,1),  #End of Storm
  Time.new(2012,11,10)   #End of Dataset
]

#These names correspond with the KML styles for coloring
time_frames = ["before", "during", "after"]

triangle_lengths = []

#Go to the Twitterer collection
Twitterer.where(:triangle_area.gte => 0).limit(nil).each_with_index do |user, index| 

  triangle_lengths << user.triangle_perimeter

  if (index%100).zero?
    print "."
  elsif (index%1001).zero?
    print index
  end
    
end #End iterating over users

r = RSRuby.instance

r.png("../img_exports/triangle_perimeters_graph.png",:height=>600,:width=>800)
r.plot( 
  { :x=>(1..triangle_lengths.length).to_a,
    :y=>triangle_lengths.sort.reverse, 
    :log=>'y', :ylab=>'Triangle Areas',
    :xaxt=>'n',:xlab=>"Users"
  })
r.eval_R "dev.off()"






