# February 11, 2015
# 
# Show where users are tweeting from -- show all the points? Is that a good idea?
#
#

require '../config'

require 'models/twitterer'
require 'models/tweet'

filename = 'less_affected_users'
limit = nil

#Prepare a GeoJSON file
geojson_outfile = EpicGeo::Writers::GeoJSONWriter.new(filename: "../datasets/geo_distribution/#{filename}")
geojson_outfile.write_header

fav_users = ["PhanieMoore", "mattgunn", "iKhoiBui", "LynnKatherinex3"]

results = Twitterer.where(
                :base_cluster_risk.gte => 100
              ).limit(limit)

puts "Query found #{results.count} users"

results.each do |user|

  puts "Processing User: #{user.handle}..."
  
  #Write all of their tweets? No, crazy!
  # geojson_outfile.literal_write_feature(
  # {type: "Feature", properties: {handle: user.handle}, geometry: {type: "MultiPoint", coordinates: user.tweets.collect{|tweet| tweet.coordinates['coordinates']}}}.to_json)
  
  geojson_outfile.literal_write_feature(
      {type: "Feature", properties: {handle: user.handle}, geometry: {type: "Point", coordinates: user.cluster_locations[user.base_cluster]}}.to_json
    )
end

geojson_outfile.write_footer
