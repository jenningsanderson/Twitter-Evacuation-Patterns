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


#Different types of stats to get
triangle_areas = []
triangle_perimeters = []
isoceles_ratios = []

users = {}

#Go to the Twitterer collection
Twitterer.where(:triangle_area.gte => 0).limit(nil).each_with_index do |user, index|

  users[user.id_str] = {

    :isoceles_ratio => (user.before_during / user.during_after), #The closer to 1, the better
    :triangle_perimeter  => user.triangle_perimeter

  }

  #Visual Status Update
  if (index%100).zero?
    print "."
  elsif (index%1001).zero?
    print index
  end
    
end #End iterating over users

r = RSRuby.instance

# Triangle Perimeters
# r.png("../img_exports/triangle_perimeters_graph.png",:height=>600,:width=>800)
# r.plot( 
#   { :x=>(1..triangle_perimeters.length).to_a,
#     :y=>triangle_perimeters.sort.reverse, 
#     :log=>'y', :ylab=>'Triangle Areas',
#     :xaxt=>'n',:xlab=>"Users"
#   })
# r.eval_R "dev.off()"


# Triangle Ratios

users.sort_by{ |user, values| values[:triangle_perimeter] }.each do |user, values|

  triangle_perimeters << values[:triangle_perimeter]
  isoceles_ratios << values[:isoceles_ratio]

end

r.png("../img_exports/isoceles_ratio_V_perimeter.png",:height=>600,:width=>800)
r.plot( 
  { :x=>triangle_perimeters,
    :y=>isoceles_ratios, 
    :ylab=>'Isoceles Ratios',
    :xlab=>"Triangle Perimeters",
    :log=>'xy'
  })
r.eval_R "dev.off()"






