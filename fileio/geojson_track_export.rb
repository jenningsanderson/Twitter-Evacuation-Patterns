# Write a GeoJSON of a user's track (just critical locations)
#
# => Also want the ability to grab a really good Tweet or two for visual wow!

require 'config'

require 'models/twitterer'
require 'models/tweet'

filename = "perfect_evacuators_2"
limit = 5

#Prepare a GeoJSON file

geojson_outfile = EpicGeo::Writers::GeoJSONWriter.new("../exports/#{filename}")
geojson_outfile.write_header


fav_users = ["PhanieMoore", "mattgunn", "iKhoiBui", "LynnKatherinex3"]

results = Twitterer.where(
                :handle.in => fav_users
              ).limit(limit)

puts "Query found #{results.count} users"

results.each do |user|

  puts "Processing User: #{user.handle}..."

  
  before_home = {:type => "Point", 
  	          :coordinates => user.cluster_locations[user.base_cluster]}

  geojson_outfile.write_feature(before_home, {:handle=>user.handle, :type=>"Before Storm"})
  
  shelter_loc = {:type => "Point",
  			  :coordinates => user.cluster_locations[user.during_storm_cluster]}

  geojson_outfile.write_feature(shelter_loc, {:handle=>user.handle, :type=>"During Storm"})

  user.tweets.select{|t| t.date > Date.new(2012,10,28) and t.date < Date.new(2012,10,30)}.each do |tweet|
  	geojson_outfile.write_feature(tweet.coordinates, {:handle => user.handle, :date=>tweet.date, :text=>tweet.text})
  end
  
  # #The user's "during storm movement"
  # geometry = {:type=>"LineString", :coordinates=>user.during_storm_movement}
  # properties = {:handle => user.handle, :tweets=>user.tweet_count}


  # geojson_outfile.write_feature(geometry, properties)


end

geojson_outfile.write_footer
