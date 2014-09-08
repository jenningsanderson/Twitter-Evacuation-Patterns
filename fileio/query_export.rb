# KML Export
#
# Write a KML file of Users and their tweets from the Twitterers collection
#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'

filename = "julinedelucci"
limit = 100

#Prepare a KML file
puts "Starting the following KML File: #{filename}"
kml_outfile = KMLAuthor.new("../exports/#{filename}.kml")
kml_outfile.write_header("KML Output of Specific Users")
write_3_bin_styles(kml_outfile.openfile)
#Should also add a style here


#Prepare an HTML File
html_export = HTML_Writer.new("../exports/#{filename}.html")
html_export.write_header('HTML Export of user search')


#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

sandy_dates = [
  Time.new(2012,10,19), #Start of dataset
  Time.new(2012,10,28), #Start of storm
  Time.new(2012,11,1),  #End of Storm
  Time.new(2012,11,10)  #End of Dataset
]

tweet_limit = 10

#These names correspond with the KML styles for coloring
time_frames = ["before", "during", "after"]

#Search the Twitterer collection
results = Twitterer.where(
                :handle => "julinedelucci"
              ).limit(limit).sort(:handle)

puts "Query found #{results.count} users"

results.each do |user|

  print "Processing User: #{user.handle}..."

  binned_tweets = user.split_tweets_into_time_bins(sandy_dates)

  user_kml_folder = {
    :name     => "#{user.handle} [#{user.sip_conf} | #{user.evac_conf}]",
    :folders => [],
    :features => [user.userpath_as_epic_kml]
  }

  binned_tweets.each_with_index do |time_slice, index|

    time = time_frames[index]

    folder = {:name => time, :features => []}

    #puts "In this folder: #{time_slice.length}"

    time_slice.each do |tweet|
      folder[:features] << tweet.as_epic_kml(style=time)
    end

    user_kml_folder[:folders] << folder
  end

  #Write user tweets to HTML
  this_content = {:name=>"#{user.handle} [#{user.sip_conf.round} | #{user.evac_conf.round}]", :content=>[]}

  user.tweets.each do |tweet|
    this_content[:content] << {:date => tweet.date, :text => tweet.text}
  end

  html_export.add_content(this_content)

  #puts "Total Tweets: #{user.tweets.count}"

  #Finished with this user, write the folder
  kml_outfile.write_folder(user_kml_folder)
  print "done\n"
end

#Finally, close the files...
kml_outfile.write_footer
html_export.write_navigation("User List")
html_export.write_content
html_export.close_file
