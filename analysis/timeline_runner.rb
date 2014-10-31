'''
This file connects to Google Drive and aggregates all of the coding data into csv
files which are then easily read by r or Python for data viz / analysis

This file also connects to the Twitterer MongoDB to get information on the clusters (*Sometimes)
'''

require_relative '../config' # Gives us nearly everything, including EpicGeo
require_relative 'TimeLineBuilder'



#Variables
collection = "HurricaneSandyEvacuationCoding"
write_directory  = "NJ_Exports"

extension = ""
rows      = 17280 #10 days

#Main runtime
if __FILE__ == $0

	wb = GoogleDriveAccess.new(collection: collection)
	session = wb.session

# 	#Find the spreadsheets we're looking for
	session.spreadsheets.each do |spreadsheet|
		
		# Specify which sheets we want (Don't be updating all of them)
		# Right now it's just calling the NJ users to code
		if spreadsheet.title =~ /NJ_UsersToCode-\d$/
			
			spreadsheet.worksheets.each do |worksheet|
				
				unless worksheet.title == "TOC"
					puts worksheet.title
					# Now that we have a worksheet -- let's make a TimeLine out of it.

					# build a timeline,
					timeline = TimeLineBuilder.new(worksheet: worksheet, write_directory: write_directory)

					#Read it
					timeline.read

					#Write it
					timeline.timeline_to_csv(rows: rows, extension: extension)
				end
			end
		end
	end
end