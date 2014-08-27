#
# Gets a user's full contextual stream and writes it to HTML
#
#
require 'rubygems'
require 'bundler/setup'
require 'epic-geo'

require 'time'

require_relative '../models/twitterer'
require_relative '../models/tweet'

#Static Setup
MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'


START_DATE = Time.new(2012,07,01)
END_DATE   = Time.new(2012,12,31)

#Find the document on the server
def retrieve_file(name)

	tweets = []

	root_path = "/home/kena/geo_user_collection/"

	#Get the subcategory
	if name[0] =~ /[[:alpha:]]/
		alph = name[0].downcase
	else
		alph = 'non'
	end

	user = name.downcase

	file_path = nil
	in_stream = nil

	(1..6).to_a.map!{|num| "geo#{num}"}.each do |section|
		test_path = "#{root_path}#{section}/user_data/#{alph}/#{user}-contextual.json"
		if File.exists? test_path
			file_path = test_path
			in_stream  = File.open(file_path,'r')
			break
		end
	end

	unless file_path.nil?
		puts "Found the path, now reading from: #{file_path}"

		#Now read the stream and return the Hash
		begin
			reg_count = 0
			geo_count = 0
			in_stream.each do |line|
				tweet = JSON.parse(line.chomp)
	        	
	        	if tweet['coordinates']
					geo_count += 1
				end
				reg_count +=1

				date = Time.parse(tweet["created_at"])

				if (date > START_DATE) and (date < END_DATE)
					tweets << {:date => date.to_s, :text=>tweet["text"] }
	          	end
			end
	    	puts "----------Geo Ratio for #{user}: #{geo_count} / #{reg_count}---------------\n"
	    rescue => e
	    	p $!
	    	puts e.backtrace
	    	puts "Stream may not have existed for: #{user}"
	    end
	    if tweets.length > 0
			return tweets.sort_by{|tweet| tweet[:date]}
		else
			puts "No tweets!"
		end
	else
		puts "Error, unable to find the stream"
		return false
	end

end

#====================== Runtime down here


filename = "ContextualStreamZoneA"

#Prepare an HTML File
html_export = HTML_Writer.new("../exports/#{filename}.html")
html_export.write_header('HTML Export of user search')


# users = ["_dbourret","AAJorgensen","aladesnr","alex55santino","AliMoss","amberjsmith","AndreaEPalesh","annafdifiore","anneeoanneo","antimoshel","ArnellMilton","arojass","aychdee12","BaconSeason","bdotdub","benbroderick","bencashfarouq","bldglvr","bobbyberk","BrianHackathorn","BROYUMAD","bryanthatcher","ByronBradshaw","c4milo","cawinemerchants","celinejade_","cem3","CharlieF03","ChefEvaBBQs","cheftommyt99","cherishj82","chinatheperson","CHULYAKOVDESIGN","conrad","contentmode","cooper_smith","coreybhale","Countertenor77","D_J721","d0nnatr0y","DaKiNgOfPrUsSiA","DaReal_JrJones","DarylLang","deinonino","derrickc82","diamondz_shine","dN0t","domhall","E_M0N3Y","eelain212","EffinwitESH","efp161122","elisesp","eoghandillon","ericabrooke12","EricaLynnYoung","estarp","eunicek","FakejoyClothing","FireTheCanon","flu","FoxyQuant","fredstardagreat","fvisaya","gabor","GaryAlonyNYC","gemmathompson","Gina_Hackett","GlamAiye","glubwilsen","gregchopp","Hardrocker721","heathermaemusic","hoff","honeyberk","hothansel","idmbassoon","ikebrooker","JamesMarotta_","JanaeR64","JayresC","jdlevite","jeremy1st","Jfranc0xox","Jimmy5wagga","jmascio","JoeyBoots","JonMcL","JOtton","joyellenicole","jsjohnst","JSuk","julioknales","JUSTmeALISEO","KatieeeO","KelACampbell","keniehuber","KenKoc1","kimdelcarmen","knowacki","Kpalminteri","kriistinax33","kriistinax33","KristaDeGeorge","lahappybelle","LaLaHearts","LauMc822","laurakazam","LaurenPresser","law_daddy","layfad","lesliealejandro","LiliyAbdrakhman","lmarks19","LogStair","LucaTrippitelli","lucida_console","LynnKatherinex3","madamelolo","Maisiegirl","MalloryMcMorrow","mariavalene","marietta_amato","markisphes","marotin507","mattgunn","Max_Not_Mark","mcflipper","mediadarwin","Medienheld","Melissa_Paris","meriSsy_joy","michaelclinard","michelledozois","mikelyden","misak","MIVenuto","MiZzMyRa","molly_mcgregor","monicajuniel","morgansteve","MrEspo","mstong","mtthg","NickJones5050","EastCoastJones","NYCGreenmarkets","ocelomaitl","parkertatro","PatricksBeer","paulbz","PaulHPhillips","petemall","PhanieMoore","PlatinumHDNYC","PreppygirlMZ","RadriOreamuno","RAjah1","RayDelRae","RealPedroRivera","ricardovice","rishegee","robertkohr","rockawaytrading","RockPaperSimone","SamAntar","SandyMohonathan","Sandys_Beach","sconnellan","siege925","SimsJames","SlaintePaddys","SMontaperto","squish108","steketee","stellar_jl319","StephaniePaige","stepliana","taftcard","TCsayyys","TheAngryPrepper","thenycnomad","THETonyMorrison","ThisIsDansTweet","tigerthedj","TonyQuattroIV","travisshawnhill","Trimarchi023","uthmanbaksh","VAJIAJIA","WizbyF","xmatt","yawetse","zigisitch","zomg_its_leah","zzopit"]

users = Twitterer.where(:hazard_level_before =>10).sort(:handle).collect{|user| user.handle}

users.each do |handle|
	tweets = retrieve_file(handle)
	
	if tweets
		this_content = {:name => handle, :content=>tweets}
		html_export.add_content(this_content)
	end
end 

#Finally, close the files...
html_export.write_navigation("User List")
html_export.write_content
html_export.close_file
