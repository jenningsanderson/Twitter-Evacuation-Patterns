# Movement Analysis
#
# This script is for testing/finalizing the evacuation classifying method.
#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'
require_relative '../processing/geoprocessing'

filename = "ZoneAOutput"

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

#Lets also write a KML file for visualizing this information
# kml_outfile = KMLAuthor.new("../exports/#{filename}.kml")
# kml_outfile.write_header("KML Output of Specific Users")
# generate_random_styles(kml_outfile.openfile, 30)
# write_3_bin_styles(kml_outfile.openfile)


coded_users = ["_dbourret", "AAJorgensen", "aladesnr", "alex55santino", "AliMoss", "amberjsmith", "AndreaEPalesh", "annafdifiore", "anneeoanneo", "antimoshel", "ArnellMilton", "arojass", "aychdee12", "BaconSeason", "bdotdub", "benbroderick", "bencashfarouq", "bldglvr", "bobbyberk", "BrianHackathorn", "BROYUMAD", "bryanthatcher", "ByronBradshaw", "c4milo", "cawinemerchants", "celinejade_", "cem3", "CharlieF03", "ChefEvaBBQs", "cheftommyt99", "cherishj82", "chinatheperson", "CHULYAKOVDESIGN", "conrad", "contentmode", "cooper_smith", "coreybhale", "Countertenor77", "D_J721", "d0nnatr0y", "DaKiNgOfPrUsSiA", "DaReal_JrJones", "DarylLang", "deinonino", "derrickc82", "diamondz_shine", "dN0t", "domhall", "E_M0N3Y", "eelain212", "EffinwitESH", "efp161122", "elisesp", "eoghandillon", "ericabrooke12", "EricaLynnYoung", "estarp", "eunicek", "FakejoyClothing", "FireTheCanon", "flu", "FoxyQuant", "fredstardagreat", "fvisaya", "gabor", "GaryAlonyNYC", "gemmathompson", "Gina_Hackett", "GlamAiye", "glubwilsen", "gregchopp", "Hardrocker721", "heathermaemusic", "hoff", "honeyberk", "hothansel", "idmbassoon", "ikebrooker", "JamesMarotta_", "JanaeR64", "JayresC", "jdlevite", "jeremy1st", "Jfranc0xox", "Jimmy5wagga", "jmascio", "JoeyBoots", "JonMcL", "JOtton", "joyellenicole", "jsjohnst", "JSuk", "julioknales", "JUSTmeALISEO", "KatieeeO", "KelACampbell", "keniehuber", "KenKoc1", "kimdelcarmen", "knowacki", "Kpalminteri", "kriistinax33", "", "KristaDeGeorge", "lahappybelle", "LaLaHearts", "LauMc822", "laurakazam", "LaurenPresser", "law_daddy", "layfad", "lesliealejandro", "LiliyAbdrakhman", "lmarks19", "LogStair", "LucaTrippitelli", "lucida_console", "LynnKatherinex3", "madamelolo", "Maisiegirl", "MalloryMcMorrow", "mariavalene", "marietta_amato", "markisphes", "marotin507", "mattgunn", "Max_Not_Mark", "mcflipper", "mediadarwin", "Medienheld", "Melissa_Paris", "meriSsy_joy", "michaelclinard", "michelledozois", "mikelyden", "misak", "MIVenuto", "MiZzMyRa", "molly_mcgregor", "monicajuniel", "morgansteve", "MrEspo", "mstong", "mtthg", "NickJones5050,EastCoastJones", "NYCGreenmarkets", "ocelomaitl", "parkertatro", "PatricksBeer", "paulbz", "PaulHPhillips", "petemall", "PhanieMoore", "PlatinumHDNYC", "PreppygirlMZ", "RadriOreamuno", "RAjah1", "RayDelRae", "RealPedroRivera", "ricardovice", "rishegee", "robertkohr", "rockawaytrading", "RockPaperSimone", "SamAntar", "SandyMohonathan", "Sandys_Beach", "sconnellan", "siege925", "SimsJames", "SlaintePaddys", "SMontaperto", "squish108", "steketee", "stellar_jl319", "StephaniePaige", "stepliana", "taftcard", "TCsayyys", "TheAngryPrepper", "thenycnomad", "THETonyMorrison", "ThisIsDansTweet", "tigerthedj", "TonyQuattroIV", "travisshawnhill", "Trimarchi023", "uthmanbaksh", "VAJIAJIA", "WizbyF", "xmatt", "yawetse", "zigisitch", "zomg_its_leah", "zzopit"]


evacuated_users = ["lisuhc", "DomC_", "nicolemancini", "Xsd", "aimerlaterre", "SteveScottWCBS", "MegEHarrington", "_dbourret", "anneeoanneo", "BaconSeason", "c4milo", "contentmode", "cooper_smith", "derrickc82", "eelain212", "EffinwitESH", "ericabrooke12", "FoxyQuant", "fredstardagreat", "honeyberK", "JamesMarotta_", "JayresC", "JOtton", "KenKoc1", "Kpalminteri", "kriistinax33", "lesliealejandro", "lmarks19", "LynnKatherinex3", "marietta_amato", "mattgunn", "Max_Not_Mark", "petemall", "PhanieMoore", "RayDelRae", "ricardovice", "rishegee", "robertkohr", "rockawaytrading", "SlaintePaddys", "uthmanbaksh", "steketee", "StephaniePaige", "yawetse"]

sip_users = ["alex55santino", "AliMoss", "amberjsmith", "AndreaEPalesh", "annafdifiore", "antimoshel", "ArnellMilton", "bdotdub", "bldglvr", "bobbyberk", "BrianHackathorn", "BROYUMAD", "bryanthatcher", "cem3", "ChefEvaBBQs", "cherishj82", "chinatheperson", "CHULYAKOVDESIGN", "conrad", "coreybhale", "d0nnatr0y", "DaReal_JrJones", "domhall", "E_M0N3Y", "efp161122", "elisesp", "eoghandillon", "EricaLynnYoung", "estarp", "FakejoyClothing", "flu", "fvisaya", "gabor", "GaryAlonyNYC", "gemmathompson", "Gina_Hackett", "GlamAiye", "glubwilsen", "gregchopp", "Hardrocker721", "heathermaemusic", "hoff", "hothansel", "idmbassoon", "ikebrooker", "jdlevite", "jeremy1st", "Jfranc0xox", "Jimmy5wagga", "jmascio", "JonMcL", "joyellenicole", "jsjohnst", "JSuk", "julioknales", "JUSTmeALISEO", "KatieeeO", "keniehuber", "kimdelcarmen", "KristaDeGeorge", "LaLaHearts", "laurakazam", "LaurenPresser", "law_daddy", "layfad", "LiliyAbdrakhman", "LogStair", "LucaTrippitelli", "lucida_console", "madamelolo", "Maisiegirl", "MalloryMcMorrow", "mariavalene", "markisphes", "marotin507", "mcflipper", "mediadarwin", "Medienheld", "meriSsy_joy", "michaelclinard", "michelledozois", "mikelyden", "misak", "MIVenuto", "MiZzMyRa", "molly_mcgregor", "monicajuniel", "morgansteve", "MrEspo", "mstong", "mtthg", "NickJones5050,EastCoastJones", "ocelomaitl", "parkertatro", "PatricksBeer", "paulbz", "PaulHPhillips", "RealPedroRivera", "sconnellan", "siege925", "SimsJames", "squish108", "stellar_jl319", "PreppygirlMZ", "stepliana", "taftcard", "TheAngryPrepper", "thenycnomad", "THETonyMorrison", "ThisIsDansTweet", "tigerthedj", "travisshawnhill", "Trimarchi023", "VAJIAJIA", "WizbyF", "xmatt", "zigisitch", "aladesnr", "arojass", "celinejade_", "diamondz_shine", "JanaeR64", "Melissa_Paris", "LauMc822"]

def add_user_cluster_to_kml(user, kml_file)

	user_folder = {:name=> user.handle, :folders=>[], :features=>[]}

	unclassified = {:name=>"Unclassified", :features=>[]}
	user.unclassified_tweets.each do |tweet|
		unclassified[:features] << tweet.as_epic_kml(style="after")
	end
	user_folder[:folders] << unclassified

	user.clusters.keys.each_with_index do |k, index|
		this_folder = {:name=>k, :features=>[]}
		user.clusters[k].each do |tweet|
			this_folder[:features] << tweet.as_epic_kml(style="r_style_#{index+1}")
		end
		user_folder[:folders] << this_folder
	end
	kml_file.write_folder(user_folder)
end


results = Twitterer.where( 
	# :hazard_level_before => 50
	:unclassified_percentage.lte => 50,
	# :unclassifiable.ne => true,
	:tweet_count.gte => 100,
	# :hazard_level_before => 10
	:handle.in => evacuated_users

).limit(nil).sort(:tweet_count)

query_size = results.count
puts "Found #{query_size} users"

evacuators = 0
unclassified = 0
shelter_in_placers = 0

results.each_with_index do |user, index|

	puts "#{user.handle} has #{user.tweet_count} tweets; #{user.unclassified_percentage}% are non-cluster"
	puts "------------------"
	puts "Before home: #{user.before_home_cluster}"
	puts "After home: #{user.after_home_cluster}"

	clusters_of_interest = user.clusters_per_day.reject{|k,v| k.to_i<300 or k.to_i>314}

	clusters_of_interest.sort_by{|k,v| k}.each do |k,v|
		puts "#{k} => #{v}"
	end

	#Run the calculator
	user.movement_analysis

	unless user.unclassifiable
		puts "SIP: #{user.sip_conf}"
		puts "Evac: #{user.evac_conf}"
		if (user.evac_conf - user.sip_conf) > 0
			evacuators += 1
			user.shelter_in_place = nil
		elsif (user.sip_conf - user.evac_conf) > 0
			user.shelter_in_place = true
			shelter_in_placers +=1
		else
			unclassified += 1
			user.shetler_in_place = nil
		end
	else
		unclassified += 1
		puts "Unclassifiable"
	end

	# user.save
	
	# add_user_cluster_to_kml(user, kml_outfile)

	puts "==================\n\n"

end

puts "Found #{query_size} Users."
puts "Found #{evacuators} Evacuators."
puts "Found #{shelter_in_placers} Shelter In Placers." 
puts "Unclassified: #{unclassified}."

# kml_outfile.write_footer
