# KML Export
#
# Write a KML file of Users and their tweets from the Twitterers collection
#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'

filename = "potential_evacuators_not_limited_to_evac"
limit = nil

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
  Time.new(2012,11,10)   #End of Dataset
]

#These names correspond with the KML styles for coloring
time_frames = ["before", "during", "after"]

#Search the Twitterer collection
results = Twitterer.where( 
                 :before_after.lte=> 50,
                 :isoceles_ratio.gte => 0.99,
                 :isoceles_ratio.lte => 1.01,
                 :triangle_perimeter.gte=> 1000,
                 :triangle_perimeter.lte=> 500000,
                 #:triangle_perimeter.lte => 1000,
                 :affected_level.lte => 2
              ).limit(limit).sort(:handle)

puts "Query found #{results.count} users"

results.each do |user|

  print "Processing User: #{user.handle}..."

  binned_tweets = user.split_tweets_into_time_bins(sandy_dates)

  user_kml_folder = {
    :name     => user.handle,
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

    poi = user.instance_eval(time.to_s)

    user_kml_folder[:folders] << folder

    user_kml_folder[:features] <<
      user.point_as_epic_kml(time, poi[0],poi[1],time)
  end

  #Write user tweets to HTML
  this_content = {:name=>user.handle, :content=>[]}

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
