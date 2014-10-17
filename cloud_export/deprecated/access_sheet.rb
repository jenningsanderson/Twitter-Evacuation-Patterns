require 'google_drive'

require_relative 'g_drive_functions' #I should rename this
require_relative 'google_sheet.rb'

#Login
config,credentials = read_config
print "Connecting to Google Drive..."
session = GoogleDrive.login(credentials['google_username'], credentials['google_password'])
print "done \nConnecting to Collection..."
coll = session.collection_by_title("HurricaneSandyEvacuationCoding")
print "done\n"

def clear_codes(sheet)
	(4 .. sheet.num_cols).each do |column|
		(2..sheet.num_rows).each do |row|
			unless sheet[row,column] == ""
				sheet[row, column] = ""
			end
		end
	end
	sheet.save
end

#Access the sheets:
#ws = session.spreadsheet_by_key("pz7XtlQC-PYx-jrVMJErTcg").worksheets[0]

new_columns = [	"Sentiment 1", "Preparation 1", "Movement 1", "Reporting on Environment 1", "Collective-Information 1","Comments 1","",
	"Sentiment 2", "Preparation 2", "Movement 2", "Reporting on Environment 2", "Collective-Information 2","Comments 2","",
	"Sentiment 2", "Preparation 3", "Movement 3", "Reporting on Environment 3", "Collective-Information 3","Comments 3","",
	"Sentiment 3", "Preparation 4", "Movement 4", "Reporting on Environment 4", "Collective-Information 4","Comments 4","",
	"Sentiment 4", "Preparation 5", "Movement 5", "Reporting on Environment 5", "Collective-Information 4","Comments 5",""]

session.spreadsheets.each do |spreadsheet|
	
	#Specify which sheets we want (Don't be updating all of them)
	if spreadsheet.title =~ /CodingRound2_\d+/
		
		spreadsheet.worksheets.each do |worksheet|
			begin
			
				# #Worksheet is now each user
				puts worksheet.title
				
				# #Add the new column headings
				new_columns.each_with_index do |column, index|
					worksheet[1,index+4] = column
				end
				worksheet.save

				# #Clear the existing codes
				# sheet = clear_codes(worksheet)
			rescue
				puts "Something, somewhere went wrong"
				puts $!
			end
		end
	end
end