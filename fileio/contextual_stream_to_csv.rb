_start =  Time.new(2012,10,22)
_end   =  Time.new(2012,11,14)

#We're running on the server!  here we go!
require_relative '../server_config'
require_relative '../cloud_export/full_contextual_stream'
#Because it's meant to be run on the server

write_directory = './csv_out/'

contextual_stream = FullContextualStreamRetriever.new(
	start_date:  _start,
	end_date:    _end,
	root_path:   "/home/kena/geo_user_collection/" )


users = ["Tocororo1931","Leslie_reilly","kr3at","marietta_amato","haleighbethhh","morgandube","Nikki_DeMarco","rutgersguy92","aidenscott","RedJazz43","onacitaveoz","just_teevo","leah_zara","D_Train86","Kren9","DJsonatra","mynameisluissss","JL092479","Antman73","Caitles16","danielleleiner","ACPressLee","Scott_Gaffney","ericaNAZZARO","txcoonz","KaliPorteous","OMGItssJadee","jmnzzkr","AmberAAlonzo","DomC_","mnapoli765","BleedBlue0415","TayloorKirsch","Zach_Massari10","CluelessMaven","PainFresh6","Roze_316","DevenMcCarthy","Anathebartender","forero29","KBopf","b_mazzz","compa_tijero","Christie_Jenna","DDSethi","stevewax","JoeeSmith19","iKhoiBui","kcgirl2003","ColleenBegley","Haylee_young","Aram2323,reyli24","Sara_Persiano"]

users.each do |handle|

	tweets = contextual_stream.get_full_stream(handle)
	puts "Total tweets: #{tweets.length}"

	File.open(write_directory+handle+'.csv', "w") do |file|  
		tweets.each do |tweet|
			file.write "#{tweet[:Date]}, #{tweet[:Text]}\n"
		end
	end
end

