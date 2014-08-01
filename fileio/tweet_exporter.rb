#
# Do I still need to use the require if I'm using the bundler?
#
#
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

#Open the export file
html_export = HTML_Writer.new('../exports/test_affected_users.html')
html_export.write_header('Affected Users')

#Go to the Twitterer collection
Twitterer.where(:affected_level => 1).limit(100).sort(:handle).each_with_index do |user, index|

	this_content = {:name=>user.handle, :content=>[]}

	user.tweets.each do |tweet|
		this_content[:content] << {:date => tweet.date, :text => tweet.text}
	end

	html_export.add_content(this_content)

end
html_export.write_navigation
html_export.write_content

html_export.close_file



