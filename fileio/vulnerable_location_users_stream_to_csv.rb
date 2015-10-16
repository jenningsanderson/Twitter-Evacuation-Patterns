_start =  Time.new(2012,10,22)
_end   =  Time.new(2012,11,07)

require 'csv'
require_relative '../modules/contextual_stream'

contextual_stream = ContextualStream::ContextualStreamRetriever.new(
	start_date:  _start,
	end_date:    _end,
	root_path:   "/home/kena/geo_user_collection/" )

red_hook_close = {name: "RedHookClose", users: ["jameswm4","anneeoanneo","weitchou","jessecfriedman","sarikamin","rich_jones","latenightgripe","dubzny","mavonderhaar","tommybennett","briennewalsh","raeinbk","keenankid1","jherbertartist","bannedinjapan","katehable","pnotaro","joshuastern","lightoutsrock","djfreakyfizzle","vdonikian","jrjeffrey","jaylee66","wizbyf","_spinoff","katekellycnbc","emilyjean_kemp","ceonyc","sionfullana","tenantsupstairs","brookelynphoto","ravenandcrow","llacour","julian_dunn","mmmpork","michaelmaag","brekkefletch","jaytroop","moyamcallister","goto10","alanarkin","harlanvaughn","ouraugust","nadstina","joliecantina","noahd1","untulis","metalchopstick","erictremblay","bodysoulrest","stellar_jl319","pobermeier","byronbrewer"]}
red_hook = {name: "RedHook", users: ["jameswm4", "sass_princess", "brianhackathorn", "ryanhascooties", "carlfranzen", "davidjal", "futuraprime", "pursuitofny", "bluemarblebk", "anneeoanneo", "melanywatson", "daltondeschain", "etravelproject", "beaulebens", "vargasteph", "katielusso", "weitchou", "allenshieh", "benbrener", "chissyn", "maurilax", "nicolemorgan25", "monicajuniel", "robertkohr", "rymilles", "phaniemoore", "dovness", "annienyhc", "jaylee66", "sarikamin", "brm", "theyuway", "ryanallenspears", "kende", "alexmoseman", "enoogs", "djdogre", "semensemble", "n3xt2stupid", "dubzny", "orlibeth", "wizbyf", "mirandarae28", "acleankegsir", "markhmanning", "patpizzy", "mavonderhaar", "austrazub", "tacumabaye", "conrad", "ilovemylexus", "jeremylechtzin", "jessiezapo", "cvmusic", "matteatsnyc", "jlwgreg", "trevjacobs", "ninammfoto", "bkessler", "rich_jones", "akajulez", "jju73", "townsendhagen", "ebpersons", "forefrontbk", "petemall", "ivanper4", "incognegro22", "kjsteag", "daejafallas", "davidezell", "os_kidd", "grimmone35", "zaidibirin", "jaimerockstar", "joeyturnpike", "derosa_is_dead", "filmbizrecyclin", "vsindha", "jherbertartist", "bkhayz", "jmpelz", "robaurelius", "wilsonfilogamo", "garyalonynyc", "michael_chis", "dentritic", "moyamcallister", "glamaiye", "whatsallydoing", "alexaizenberg", "hollville", "sundaegirl108", "carriedaway16", "raeinbk", "yatcher", "suzanne_england", "zblock1", "kaseybthomas", "phillipcrosby", "geminiimatt", "dapperalchemist", "austindill", "imatrisk", "macklannahan", "richard_scholl", "sterlingaclay", "bannedinjapan", "mirgoes2eleven", "johnjschwarz", "ashesto_ashes", "alyssenicole", "wayofthedodo", "thedantaylor", "phidesign", "gideon_lester", "designhype", "awkwardchef", "nickjablonski", "doncadora", "realryanwelch", "mcsassy86", "ewandaley", "bedstuybeauty", "chajax", "arainert", "mmmpork", "tangphillip", "ouraugust", "tilemachus", "emmabgardner", "authenticjon", "laslugocki", "keenankid1", "theguze", "jobronze", "stayc_lassy", "iamcolossus", "joeyrich1218", "trinitywallst", "mistermcneilo", "claireanselmo", "artsyfartsydvds", "laurenzee123", "awe3", "andyjohnjoseph", "jbwphoto", "fjorder", "mediamindy", "leefromamerica", "jacespade", "_kris", "freckles331", "ehershey", "wassupjodi", "damianodemonte", "boogaloo618", "pnotaro", "mallorymcmorrow", "pozzonyc", "robinschaer", "emmasphere212", "daniellelotardo", "hananaahh", "tmilewski", "carolinebytes", "alextcone", "jameslkimmel", "dantekgeek", "sheritajanielle", "binhthai", "dancinfeet83", "csumen", "katehable", "thatnavinraj", "darrellsilver", "natefrench18", "dpietrangelo", "sabrinster", "keithuhlich", "jessecfriedman", "rockywoolford", "bethweinstein", "kpaoletta", "niecekaoir", "ultrafonk", "megkoval", "mcedit47", "tay_125_", "egfinnell", "theambershow", "emilyjean_kemp", "sionfullana", "rheller0708", "amy_bedford", "tinoslad", "jcmealla", "achornback", "andersramsay", "billie_jeanne", "everythingsaok", "kaightshop", "d_j721", "robertnmurray", "lightoutsrock", "rbonifacino", "veintreatmentny", "swimtennisfilm", "jsukach", "defendyours", "malbonnington", "wrhaynes", "missbrooke326", "kittycolorist", "lauren_lind", "bereninga", "tenantsupstairs", "rrn3", "mlcooley", "originalspin", "vectorheartss", "joshuastern", "ericmcclurebk", "adkap", "rpmkel", "shaila", "clausrodgaard", "1lx", "nettdrone", "chicavahoney", "tribecataco", "epc", "mattlament", "tommybennett", "latenightgripe", "heymikewaskom", "ang_byrne", "ddmcpherson", "sawhillbusre", "mtthg", "misak", "stillhip", "yolofahad", "mr_casal", "djfreakyfizzle", "queensdemocracy", "thesocialwhore", "itstwhite", "imryanelizabeth", "alexgkern", "functime", "vdonikian", "alissamarie", "rspberryeggplnt", "indy5music", "gregchopp", "bloody_mouth", "jrjeffrey", "mandyofish", "joeymanin", "chinamillman", "thibautmarquis", "kaulec", "psilao", "heyitsaleesha", "jaytroop", "betsyrate", "biancacpassos", "thekevena", "thehomiesantos", "evankonwiser", "pedro2nd", "idrichards", "ladiee", "cfohlin", "julian_dunn", "amyzroeder", "noahpreminger", "hiren1012", "_spinoff", "plaidsandwich", "dayna_doll", "michaelmaag", "edwardespitia", "kiasthoughts", "harlanvaughn", "pamelavenbass", "davidbisono", "meeeshe", "followmdm", "worldmattworld", "kacie_lea", "llacour", "sol666soul", "tarahfo", "brookelynphoto", "schultzinit", "bttyanne", "porcelain72", "monie349", "katekellycnbc", "derrickc82", "edelsingh", "breezethroughit", "ccwii", "chadkaydo", "gothamveg", "weisgall", "mcflipper", "bldglvr", "shelbywelinder", "alannyc", "shu_rosaline", "jkoostdijk", "ceonyc", "yangbin88olp", "allybmartin", "michymak", "theserenagoh", "kingsleyharris", "jackie77m", "lagataphotonyc", "nycctfab", "exurbanexile", "bupbin", "samhorine", "michelenyc", "jmgreenawalt", "jnewmannyc", "raywert", "jericajazz", "abdulsmith", "sareneleeds", "gettintwipsy", "laurenatkiehls", "amoraine", "cajigao", "gwynnettst", "prophet_terrell", "dangaba", "jperiodbk", "emilahp", "reillyodonnell", "kmbatty", "mariannemurph", "_skydeity", "shneusk", "matthewaquilone", "atease", "mokindo", "briennewalsh", "kenzafourati", "jeanellemak", "soccercentrale", "metalchopstick", "fozzielogic", "cara_bloch", "joliecantina", "xaviersg", "ladestro", "janieskitchen", "danaliroasters", "flu", "thomaslikins", "bodysoulrest", "danielleekaplan", "sefasays", "julianneatkins", "katiekansas", "heyguey", "stevewax", "kellyclaunch", "bjsib", "cdima", "grochejr", "tiffym", "caseyhatch", "lucysilb", "alexjocelyn1", "nicolechismar", "faridkader", "jonathankopp", "byronbradshaw", "peter_silsbee", "danielr11220", "chelsey_kocian", "ad454", "ajlawrence", "ahmedley", "nicholalexander", "harrislynn", "railbirdcory", "adamjburke", "workfreelyblog", "stepliana", "ravenandcrow", "jpnyc", "erictremblay", "derricktrotman", "sfc_coachd", "nadstina", "clpreg", "p00nie", "sigurdkv", "patrykbot", "goto10", "drmirror", "plocke", "sindha_ravi", "noahd1", "amonter5", "alanarkin", "diyaj", "akm_nyc", "ankushnarula", "tiffanyhouser", "killerfemme", "homagebrooklyn", "kblanqua", "drwho131", "partyliz", "isaac_b", "brekkefletch", "calteoh", "zachbrock", "jocluiz12", "ubbulls1", "untulis", "tylerjhelms", "y0urher0", "dani_marie92", "decharlus", "jsphotoart", "porter44", "rosemaryrr", "valer0us", "aeclearwater", "sharipep", "melissawilfley", "bradkay", "nnebeluk", "armindak", "buissereth", "jonnii", "sushilovinfun", "jaimejin", "digenger", "woodsarawood", "sn0wcap", "iamlegend_718", "thehbombz", "thisismarkc", "jamesliebman", "myma1313", "crabapplenyc", "essiegue", "spiczillaaa", "byronbrewer", "adrianamisoul", "effinwitesh", "kelacampbell", "maperencap", "patwentling", "cyantifik", "jrloessy", "usha_joy", "thejackamo", "russomandofabio", "medienheld", "lianawrightmark", "johnnycheeks7", "live2dreamtoday", "dimsumnyc", "thecolemaniac", "shwetanyc", "julienneschaer", "heyfeifer", "acolorfulplate", "pobermeier", "cmenchaca", "csprincess95", "lisalubrano", "ameelzs", "stellar_jl319", "villadh", "rvillacarillo", "j9thedancinchef", "mattwheeler", "dawnjfraser", "thatnickbrady", "funksoul_sista", "wherescafr", "sobrenatural7"]}
brighton = {name: "Brighton", users: ["bencashfarouq", "chuckbegettinit", "aniceberg", "masterjao", "liatzikk", "lifevestinside", "moesalama", "rivkind", "max4f", "e_m0n3y", "jameela13", "cankneema", "lalahearts", "itzikc123", "tofiquee", "noreanc", "bronxbrn", "josephbenhaim", "ladyborsa", "zeroxomega", "sammyraps", "mizzmyra", "josephmizrahi", "fredbugatti", "bman212", "horhayblanco", "sheeravenue", "lunaparknyc", "ireenah", "maryellen1107", "joesaban", "murraydweck", "john_el", "tombasgil", "xxbang_bang", "danielwelden", "steph_m_rod", "amanda_xtelle", "ironicironnie", "shazimc", "barryy", "pminze", "dennis_k", "thegqsoviet", "dark_iceberg", "a1exus", "roberto_correab", "angelagomez19", "sandeeglam", "ushercooloff", "niggadr3w", "nickiimars", "fdrmx", "ronpodovich", "elifefe1907", "tomasaid", "freddysbar1", "leftylucyny", "valahoy", "mitsue719", "thegoldnjew", "lizsetton", "asadhafeez25", "b_wutan", "saykoolmaye", "katbabez", "asburyhoward", "bklynsfinest5", "la_nastenka", "abiet90", "haydeecastillo5"]}
rockaway = {name: "FarRockaway", users: ["qtwiddaboot", "readyrock7", "tigerthedj", "ryanbaesian", "thecgcclan", "playhutttplay", "nueraent2", "chinkeyeyez3", "dj2020", "aladesnr", "missmochalatte2", "julioknales", "marotin507"]}

[red_hook_close, red_hook, brighton, rockaway].each do |location|

	CSV.open(location[:name]+'_users.csv', "w") do |csv|

		location[:users].each do |handle|

			contextual_stream.set_file_path(handle)
			tweets = contextual_stream.get_full_stream(geo_only=false)

			puts "Total tweets: #{tweets.length}"
			tweets.each do |tweet|
				csv << [ handle, tweet[:Id], tweet[:Date], tweet[:Text], tweet[:Coordinates] ]
			end
		end
	end
end