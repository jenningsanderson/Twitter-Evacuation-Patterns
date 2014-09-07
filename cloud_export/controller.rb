#Requirements
require 'google_drive'
require 'time'
#require 'epic-geo'

#Eventually this will get published to epic-geo
require_relative '/Users/jenningsanderson/Documents/epic-geo/lib/epic-geo'

require_relative 'g_drive_functions'
require_relative 'google_sheet'
require_relative 'full_contextual_stream'
require_relative '../models/twitterer'
require_relative '../models/tweet'

# Base Configuration 
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

config,credentials = read_config
print "Connecting to Google Drive..."
session = GoogleDrive.login(credentials['google_username'], credentials['google_password'])
print "done \nConnecting to Collection..."
coll = session.collection_by_title("HurricaneSandyEvacuationCoding")
print "done\n"

# Make a web directory for the user (using Epic-Geo)
web_archive = HTMLArchiveMaker.new('users_to_code')
web_archive.add_style # => default stylesheet

# Make a new Google Sheet
sheets_count = 1
wb = SheetMaker.new(session, coll, 'Users To Code-1')

# Create an instance of the contextual stream accessor
_start = Time.new(2012,10,22)
_end   = Time.new(2012,11,14)
contextual_stream = nil

if ARGV[0] == "contextual"
	contextual_stream = FullContextualStreamRetriever.new(credentials[:contextual_root_path], _start, _end)
end

# Get the Users we want
results = Twitterer.where(

	:hazard_level_before => 36

).limit(20).sort(:handle)

puts "Found #{results.count} users" # => Status update

#Iterate over the results
results.each_with_index do |user, index|

	puts "\nProcessing: #{user.handle} with #{user.tweet_count} tweets"

	user_content = {:evac_conf => user.evac_conf.round, 
					:sip_conf => user.sip_conf.round,
					:tweets => []}

	#If contextual_stream is defined, then it'll grab the contextual stream.
	if contextual_stream.nil?
		user.tweets.each do |tweet|
    		user_content[:tweets] << {:Date => tweet.date, :Text => tweet.text}
  		end
  	else
		user_tweets = contextual_stream.get_full_stream(user.handle)
	end

	
	#Add the user to a web archive for sharable, easy viewing
	# =======================================================
	web_archive.add_user_page(user.sanitized_handle, user_content)
	

	# Add the user to the Google Spreadsheet
	# ======================================
	# user_sheet = wb.add_sheet(user.handle)
	# user_content[:tweets].each_with_index do |tweet|
	# 	user_sheet.add_tweet(tweet)
	# end

	# if ((index+1)%16).zero?
	# 	puts "------Writing new Workbook------"
	# 	sheets_count +=1
	# 	wb = SheetMaker.new(session, coll, "Users To Code-#{sheets_count}")
	# end

end

#Closing Functions
web_archive.write_index
