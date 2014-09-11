require 'google_drive'
require 'time'

require_relative 'g_drive_functions' #I shoudl rename this


class UserSheet

	#User columns
	@@coders = [
		jennings = {:sentiment=> 4,:prep=> 5, :evac=> 6,:sip => 7,:collective=>8 },
		kevin    = {:sentiment=> 11,:prep=> 12, :evac=> 13,:sip => 14,:collective=>15 },
		marina   = {:sentiment=> 18,:prep=> 19, :evac=> 20,:sip => 21,:collective=>22 }
	]

	def initialize( worksheet)
		@ws = worksheet
	end

	def parse_worksheet(agg_file)
		(2..(@ws.num_rows)).each do |row|
			@row = row
			date = Time.parse( @ws[row, 1] )
			
			sentiment = agg_cells(:sentiment)
			prep      = agg_cells(:prep)
			evac      = agg_cells(:evac)
			sip       = agg_cells(:sip)
			collective= agg_cells(:collective)
			
			unless sentiment.nil?
				agg_file.write_column(:sentiment, @row, sentiment)
			end

			unless prep.nil?
				agg_file.write_column(:prep, @row, prep)
			end

			unless evac.nil?
				agg_file.write_column(:evac, @row, evac)
			end

			unless sip.nil?
				agg_file.write_column(:sip, @row, sip)
			end

			unless collective.nil?
				agg_file.write_column(:collective, @row, collective)
			end
		end
	end

	def agg_cells(arg) 
		combo = []
		@@coders.each do |coder|
			val = @ws[@row, coder[arg]]
			unless val == ""
				combo << val
			end
		end

		unless combo.empty?
			return combo.uniq
		else
			return nil
		end
	end
end

class Agg_User_Sheet

	@@columns = {:sentiment=> 4, :prep=> 5, :evac=> 6, :sip => 7, :collective=>8 }

	def initialize(sheet)
		@sheet = sheet
		puts @sheet.title
	end

	def write_column(column, row, value)
		puts row, column, value
		to_write_column = @@columns[column]

		@sheet[row, @@columns[column]] = value.join(", ")
		@sheet.save
	end
end


#=============Main runtime===================#


#Login
config,credentials = read_config
print "Connecting to Google Drive..."
session = GoogleDrive.login(credentials['google_username'], credentials['google_password'])
print "done \nConnecting to Collection..."
coll = session.collection_by_title("HurricaneSandyEvacuationCoding")
print "done\n"

#Access the sheets:

#users = ["dogukanbiyik","kimdelcarmen","rchieB","fernanjos","nicolelmancini","Krazysoto","ailishbot","CharisseCrammer","jericajazz","KD804","jesssgilligan","theJKinz","TheAwesomeMom","bjacksrevenge","jefflac","roobs83","jds2001","SimoMarms","NYCGreenmarkets","c3nki","MoazaMatar","KiiddPhenom","sandelestepan","tlal2","BeachyisPeachy","cyantifik","FrankKnuck","mattgunn","Max_Not_Mark","JaclynPatrice","Rigo7x","ajc6789","yagoSMASH","polinchock","indavewetrust","CillaCindaplc2B","Javy_Jaz","eric13000","becaubs","enriqueskincare","Rivkind","janelles__world","CoreyKelly","josalazas","CapponiWho","JohnBakalian1","valcristdk","forero29","BobGrotz","CodyRodrigu3z","CoastalArtists","VSindha"]

#We can manually update these users:
users = []

session.spreadsheets.each do |spreadsheet|
	
	#Specify which sheets we want (Don't be updating all of them)
	if spreadsheet.title =~ /Users To Code-\d+/
		
		spreadsheet.worksheets.each do |worksheet|
			
			if users.include? worksheet.title.downcase
				puts "Processing: #{worksheet.title}"
				user_name = worksheet.title

				#Find the aggregate file
				number = spreadsheet.title.scan(/\d+/)[0]
				puts agg_file = "Aggregated_Coding_#{number}"
				agg_user_file = session.spreadsheet_by_title(agg_file)
				this_user_agg = Agg_User_Sheet.new(agg_user_file.worksheet_by_title(user_name))

				#Do the heavy lifting
				this_user = UserSheet.new(worksheet)
				this_user.parse_worksheet(this_user_agg)
			end
		end
	end
end
