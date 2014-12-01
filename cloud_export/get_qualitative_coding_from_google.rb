#
#
#
#
#

require_relative '../config.rb'

require 'analysis/TimeLineBuilder'

include EpicGeo

collection = "HurricaneSandyEvacuationCoding"
prefix = /NJ_UsersToCode-\d+/

# Make a new connection to the Qualitatively Coded Tweets:

connection = GoogleDriveAccess.new(collection: collection)



#Iterate over each spreadsheet in the collection
connection.collection.spreadsheets.each do |spreadsheet|

	#Find a spreadsheet with the prefix we're looking for
	if spreadsheet.title =~ prefix
		
		#Now iterate over each sheet in the spreadsheet
		spreadsheet.worksheets[1..-1].first(2).each do |worksheet|
			
			#Now get the user
			user = Twitterer.where(handle: worksheet.title).first

			puts "\n\n#{user.handle}\n"

			#Iterate over each row (Starting after headers)
			(2..(worksheet.num_rows)).each do |row|
				
				time = Time.parse( worksheet[row, 1] )

				#Does a tweet exist for *near* these times?
				puts time
				puts time.

				#For each row, iterate over the columns
				TimeLineBuilder.columns.each do |column, value|
				
					#Read the value, if it's empty, get back nil
					cell_val = worksheet[row, value]
				
					puts cell_val unless cell_val == ""
				end
			end
		end

	end
end

