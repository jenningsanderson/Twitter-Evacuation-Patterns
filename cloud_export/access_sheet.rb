require 'google_drive'

require_relative 'g_drive_functions' #I shoudl rename this

#Login
config,credentials = read_config
print "Connecting to Google Drive..."
session = GoogleDrive.login(credentials['google_username'], credentials['google_password'])
print "done \nConnecting to Collection..."
coll = session.collection_by_title("HurricaneSandyEvacuationCoding")
print "done\n"

#Access the sheets:
#ws = session.spreadsheet_by_key("pz7XtlQC-PYx-jrVMJErTcg").worksheets[0]

new_columns = ["Sentiment", "Preparation", "Evacuation", "Shelter-In-Place","Comments","","","","","",""]
session.spreadsheets.each do |spreadsheet|
	
	#Specify which sheets we want (Don't be updating all of them)
	if spreadsheet.title =~ /Users To Code-\d+/
		
		spreadsheet.worksheets.each do |worksheet|
			
			#worksheet is now each user
			puts worksheet.title
			new_columns.each_with_index do |column, index|
				worksheet[1,index+4] = column
			end
			worksheet.save
		end
	end
end

# Gets content of A2 cell.
#p ws[2, 1]  #==> "hoge"

# Changes content of cells.
# Changes are not sent to the server until you call ws.save().
#ws[2, 1] = "foo"
#ws[2, 2] = "bar"
#ws.save()
