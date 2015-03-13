# February 11, 2015
#
# Show where users are tweeting from -- show all the points? Is that a good idea?
#

require '../config'

require 'models/twitterer'
require 'models/tweet'

filename = 'all_tweets_high_risk_users'
limit = nil

start_time = Time.new(2012,10,22)
end_time   = Time.new(2012,11,02)

#Prepare a GeoJSON file
geojson_outfile = EpicGeo::Writers::GeoJSONWriter.new(filename: "/Users/jenningsanderson/Desktop/exports/#{filename}")
geojson_outfile.write_header

# fav_users = ["PhanieMoore", "mattgunn", "iKhoiBui", "LynnKatherinex3"]

results = Twitterer.where(
                :base_cluster_risk.lt => 100
              ).limit(limit)

puts "Query found #{results.count} users"
cnt = 0;
results.each do |user|

  puts "Processing User: #{user.handle}..."
  puts cnt

  user.tweets_in_time_range(start_time, end_time).each do |tweet|
    geojson_outfile.literal_write_feature(
      {type: "Feature", properties: {handle: user.handle, time: tweet.date, text: tweet.text}, geometry: tweet.coordinates }.to_json
    )
  end

  #Write all of their tweets? No, crazy!

  # geojson_outfile.literal_write_feature(
  #     {type: "Feature", properties: {handle: user.handle}, geometry: {type: "Point", coordinates: user.cluster_locations[user.base_cluster]}}.to_json
  #   )

  cnt +=1 
end

geojson_outfile.write_footer
