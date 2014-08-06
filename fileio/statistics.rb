# Statistics
#
# Various statistics to be calculated with Ruby and visualized with R.
#
# Each export should be in img_export and each piece is simply commented out
#
#   Lesson learned: Never delete rsruby code, referencing it later to understand
#   the graph is critical!
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
tweet_count = []

users = {}

#Go to the Twitterer collection
Twitterer.where(:affected_level => 2, :isoceles_ratio.ne=>nil).limit(nil).each_with_index do |user, index|

  users[user.id_str] = {

    :isoceles_ratio => (user.before_during / user.during_after), #The closer to 1, the better
    :triangle_perimeter  => user.triangle_perimeter

  }

  triangle_perimeters << user.triangle_perimeter

  tweet_count << user.tweet_count

  #Visual Status Update
  if (index%100).zero?
    print "."
  elsif (index%1001).zero?
    print index
  end

end #End iterating over users

#Start RSRuby
r = RSRuby.instance

# =============  Triangle Perimeters
# r.png("../img_exports/triangle_perimeters_graph.png",:height=>600,:width=>800)
# r.plot(
#   { :x=>(1..triangle_perimeters.length).to_a,
#     :y=>triangle_perimeters.sort.reverse,
#     :log=>'y', :ylab=>'Triangle Perimeters',
#     :xaxt=>'n',:xlab=>"Users"
#   })
# r.eval_R "dev.off()"


# Triangle Ratios
users.sort_by{ |user, values| values[:triangle_perimeter] }.each do |user, values|

  triangle_perimeters << values[:triangle_perimeter]
  isoceles_ratios << values[:isoceles_ratio]

end

puts triangle_perimeters.count
puts isoceles_ratios.count

r.png("../img_exports/isoceles_ratio_V_perimeter_affected_2.png",:height=>600,:width=>800)
r.plot(
  { :x=>triangle_perimeters,
    :y=>isoceles_ratios,
    :ylab=>'Isoceles Ratios',
    :xlab=>"Triangle Perimeters",
    :log=>'xy'
  })
r.eval_R "dev.off()"


# =============  Triangle Ratios
# users.sort_by{ |user, values| values[:triangle_perimeter] }.each do |user, values|
#   triangle_perimeters << values[:triangle_perimeter]
#   isoceles_ratios << values[:isoceles_ratio]
# end

# r.png("../img_exports/isoceles_ratio_V_perimeter.png",:height=>600,:width=>800)
# r.plot(
#   { :x=>triangle_perimeters,
#     :y=>isoceles_ratios,
#     :ylab=>'Isoceles Ratios',
#     :xlab=>"Triangle Perimeters",
#     :log=>'xy'
#   })
# r.eval_R "dev.off()"

#=============  Triangle Perimeters
# r.png("../img_exports/triangle_perimeters_graph_lte100tweets.png",:height=>600,:width=>800)
# r.plot(
#   { :x=>(1..triangle_perimeters.length).to_a,
#     :y=>triangle_perimeters.sort.reverse,
#     :log=>'y', :ylab=>'Triangle Perimeters for Users <= 100 tweets',
#     :xaxt=>'n',:xlab=>"Users"
#   })
# r.eval_R "dev.off()"


#=============  Triangle Ratios
# users.sort_by{ |user, values| values[:triangle_perimeter] }.each do |user, values|
#   triangle_perimeters << values[:triangle_perimeter]
#   isoceles_ratios << values[:isoceles_ratio]
# end
#
# r.png("../img_exports/isoceles_ratio_V_perimeter_lte100tweets.png",:height=>600,:width=>800)
# r.plot(
#   { :x=>triangle_perimeters,
#     :y=>isoceles_ratios,
#     :ylab=>'Isoceles Ratios',
#     :xlab=>"Triangle Perimeters"
#   })
# r.eval_R "dev.off()"



#===============  Tweet Count Histogram
# r.png("../img_exports/TweetCountHistogram_lte100.png",:height=>600,:width=>800)
# r.hist( {
#     :x=>tweet_count,
#     :ylab=>'Number of Users',
#     :xlab=>"Number of Tweets",
#     :breaks=>200,
#     :main=> "Tweets per User Histogram (Users with <= 100 tweets)"
#   })
# r.eval_R "dev.off()"
