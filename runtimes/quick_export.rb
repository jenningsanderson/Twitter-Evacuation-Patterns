
require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'

MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'




interesting_users = ["_dbourret","AAJorgensen","aladesnr","alex55santino","AliMoss","amberjsmith","AndreaEPalesh","annafdifiore","anneeoanneo","antimoshel","ArnellMilton","arojass","aychdee12","BaconSeason","bdotdub","benbroderick","bencashfarouq","bldglvr","bobbyberk","BrianHackathorn","BROYUMAD","bryanthatcher","ByronBradshaw","c4milo","cawinemerchants","celinejade_","cem3","CharlieF03","ChefEvaBBQs","cheftommyt99","cherishj82","chinatheperson","CHULYAKOVDESIGN","conrad","contentmode","cooper_smith","coreybhale","Countertenor77","D_J721","d0nnatr0y","DaKiNgOfPrUsSiA","DaReal_JrJones","DarylLang","deinonino","derrickc82","diamondz_shine","dN0t","domhall","E_M0N3Y","eelain212","EffinwitESH","efp161122","elisesp","eoghandillon","ericabrooke12","EricaLynnYoung","estarp","eunicek","FakejoyClothing","FireTheCanon","flu","FoxyQuant","fredstardagreat","fvisaya","gabor","GaryAlonyNYC","gemmathompson","Gina_Hackett","GlamAiye","glubwilsen","gregchopp","Hardrocker721","heathermaemusic","hoff","honeyberk","hothansel","idmbassoon","ikebrooker","JamesMarotta_","JanaeR64","JayresC","jdlevite","jeremy1st","Jfranc0xox","Jimmy5wagga","jmascio","JoeyBoots","JonMcL","JOtton","joyellenicole","jsjohnst","JSuk","julioknales","JUSTmeALISEO","KatieeeO","KelACampbell","keniehuber","KenKoc1","kimdelcarmen","knowacki","Kpalminteri","kriistinax33","kriistinax33","KristaDeGeorge","lahappybelle","LaLaHearts","LauMc822","laurakazam","LaurenPresser","law_daddy","layfad","lesliealejandro","LiliyAbdrakhman","lmarks19","LogStair","LucaTrippitelli","lucida_console","LynnKatherinex3","madamelolo","Maisiegirl","MalloryMcMorrow","mariavalene","marietta_amato","markisphes","marotin507","mattgunn","Max_Not_Mark","mcflipper","mediadarwin","Medienheld","Melissa_Paris","meriSsy_joy","michaelclinard","michelledozois","mikelyden","misak","MIVenuto","MiZzMyRa","molly_mcgregor","monicajuniel","morgansteve","MrEspo","mstong","mtthg","NickJones5050,EastCoastJones","NYCGreenmarkets","ocelomaitl","parkertatro","PatricksBeer","paulbz","PaulHPhillips","petemall","PhanieMoore","PlatinumHDNYC","PreppygirlMZ","RadriOreamuno","RAjah1","RayDelRae","RealPedroRivera","ricardovice","rishegee","robertkohr","rockawaytrading","RockPaperSimone","SamAntar","SandyMohonathan","Sandys_Beach","sconnellan","siege925","SimsJames","SlaintePaddys","SMontaperto","squish108","steketee","stellar_jl319","StephaniePaige","stepliana","taftcard","TCsayyys","TheAngryPrepper","thenycnomad","THETonyMorrison","ThisIsDansTweet","tigerthedj","TonyQuattroIV","","travisshawnhill","Trimarchi023","uthmanbaksh","VAJIAJIA","WizbyF","xmatt","yawetse","zigisitch","zomg_its_leah","zzopit"]



results = Twitterer.where(
	:handle.in => interesting_users,
	:issue.lt => 100,
	).limit(10).sort(:handle)

results.each do |user|
	unless user.handle.empty?
		print "#{user.handle},"
	
		unless user.shelter_in_place
				print "1,"
		else
				print ",1,"
		end
		
		if user.unclassifiable
			print "1,"
		else
			print ","
		end
		print "\n"
	end

end
