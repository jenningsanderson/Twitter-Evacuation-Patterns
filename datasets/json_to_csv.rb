require 'json'
require 'csv'

x = JSON.parse(File.read('./gold_sample.json'))

columns = ["Sentiment", "Reporting", "Movement","Actions","Information"]

CSV.open('output.csv', 'wb') do |csv|
	csv << ['date']+columns
	x.each do |tweet|
		date = tweet[1]["date"]
		annotations = {}
		tweet[1]["annotations"].each do |ann|
			unless ann == "None"
				annotations[ann.split('-')[0]]=ann.split('-')[1]
			end
		end
		row = [date]
		columns.each do |column|
			if annotations[column].nil?
				row << ''
			else
				row << annotations[column]
			end
		end
		csv << row
	end
end
