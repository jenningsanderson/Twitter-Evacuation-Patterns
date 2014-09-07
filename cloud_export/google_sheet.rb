require 'google_drive'

'''
The Sheet maker -- perhaps the bed maker?  har har har...
'''

class SheetMaker

	@@headers = ["Date", "Text", "Geo", "Angry","Scared","Obstinate","Charging Batteries","Preparing Transport"]
	
	attr_reader :filename

	def initialize(session, collection, filename)
		@sheet = session.create_spreadsheet
		collection.add(@sheet)
		@sheet.title= filename
	end

	def add_sheet(ws_name)
		puts "Making new worksheet: #{ws_name}"
		SingleSheet.new( @sheet.add_worksheet(ws_name), @@headers)
	end
end


class SingleSheet

	def initialize(worksheet, headers)
		@ws = worksheet
		@row_index = 1
		#Write the Row Headers
		headers.each_with_index do |header, index|
			@ws[@row_index, index+1] = header 
		end
		@ws.save
	end

	def add_tweet(tweet)
		begin
			@row_index += 1
			@ws[@row_index, 1] = tweet[:Date]
			@ws[@row_index, 2] = tweet[:Text]
			@ws[@row_index, 3] = tweet[:Coordinates]
			@ws.save
			print "."
		rescue => e
			puts "Error writing this tweet: #{tweet}"
			puts $!
		end
	end

	def save
		@ws.save
	end
end
