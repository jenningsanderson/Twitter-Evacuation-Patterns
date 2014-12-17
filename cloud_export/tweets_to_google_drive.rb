_start =  Time.new(2012,10,22)
_end   =  Time.new(2012,11,14)

if ARGV[0] == "contextual"
	#We're running on the server!  here we go!
	require_relative '../server_config'
	require_relative 'full_contextual_stream'
	#Because it's meant to be run on the server

	contextual_stream = FullContextualStreamRetriever.new(
		start_date:  _start,
		end_date:    _end,
		root_path:   "/home/kena/geo_user_collection/" )
	
	MongoMapper.connection = Mongo::Connection.new(:pool_timeout=>false)
	MongoMapper.database = 'sandygeo2'
else
	contextual_stream = nil
	require_relative '../config'
	MongoMapper.connection = Mongo::Connection.new#('epic-analytics.cs.colorado.edu', :pool_timeout=>false)
	MongoMapper.database = 'sandygeo2'
end

include EpicGeo
include EpicGeo::Writers


# Make a new Google Sheet
sheets_count = 1
wb = EpicGeo::Writers::GoogleDrive::SheetMaker.new(
		collection: "CollapsedCodingSample",
		name: 		"CollapsedCodingSampleUsers-#{sheets_count}"
	)

#Make a web directory for the user (using Epic-Geo)
web_archive = HTML::ArchiveMaker.new('CollapsedCodingSample')
web_archive.add_style # => default stylesheet
unless Dir.exists? 'CollapsedCodingSample/kml_files'
	Dir.mkdir('CollapsedCodingSample/kml_files')
end

coding_sheet_headers = ["Date","Geo","Text",
	"Sentiment","Preparation","Movement","Reporting on Environment","Collective-Information", "Comments", "Geo-Cluster",
	"Sentiment 2","Preparation 2","Movement 2","Reporting on Environment 2","Collective-Information 2", "Comments 2",
	"Sentiment 2","Preparation 3","Movement 3","Reporting on Environment 3","Collective-Information 3", "Comments 3",
	"Sentiment 2","Preparation 4","Movement 4","Reporting on Environment 4","Collective-Information 4", "Comments 4",
	"Sentiment 2","Preparation 5","Movement 5","Reporting on Environment 5","Collective-Information 5", "Comments 5"]

# Get the Users we want
#users = ["ellenmrose", "DJsonatra", "nicole_edwards4", "NickeyyDees"]
#users = ["Tocororo1931","Leslie_reilly","kr3at","marietta_amato","haleighbethhh","morgandube","Nikki_DeMarco","rutgersguy92","aidenscott","RedJazz43","onacitaveoz","just_teevo","leah_zara","D_Train86","Kren9","DJsonatra","mynameisluissss","JL092479","Antman73","Caitles16","danielleleiner","ACPressLee","Scott_Gaffney","ericaNAZZARO","txcoonz","KaliPorteous","OMGItssJadee","jmnzzkr","AmberAAlonzo","DomC_","mnapoli765","BleedBlue0415","TayloorKirsch","Zach_Massari10","CluelessMaven","PainFresh6","Roze_316","DevenMcCarthy","Anathebartender","forero29","KBopf","b_mazzz","compa_tijero","Christie_Jenna","DDSethi","stevewax","JoeeSmith19","iKhoiBui","kcgirl2003","ColleenBegley","Haylee_young","Aram2323,reyli24","Sara_Persiano"]
#users_for_kevin = ["KimberlyAdiyia", "MaNueLEmy","NickJones5050,EastCoastJones","MeatPackingNY",	"AshVickery",	"Miss_AngieLove",	"RayDelRae",	"Ez2bnicee",	"LeslieGLewis",	"CSmoothnyc",	"emadavison",	"cesarsgr",	"SupaEngineer",	"steketee",	"swannamac",	"axterix7",	"dN0t",	"sarahbachmann",	"HollyFabs",	"robertkohr",	"ayyorivera",	"kemofxckz",	"Tocororo1931",	"MicheleLaudig",	"jon3name",	"brandowBRANDOW",	"tobysmithny",	"milkshakecoma",	"layfad",	"Christhiansh",	"barbutonyc",	"DoLLaRs170",	"jmascio",	"wiseshashou",	"ashleyandalora",	"nycConfidential",	"carlossguzman",	"JRSIV81",	"GH_Velma",	"tonymayes",	"dschreib",	"nicolelmancini",	"Leslie_reilly",	"eunicek",	"cyantifik",	"DannyGarcia222",	"RO1112",	"flu",	"rjgoldsborough",	"yayito2982",	"morrissued",	"gob",	"LuLiviero",	"Myleee_",	"reubenhernandez",	"torrduer",	"HawleyDunbar",	"annafdifiore",	"noALTERjustEBO",	"tylr",	"Aram2323,reyli24",	"Harmonimages",	"zabackj",	"JanaeR64",	"igstorres",	"NathanArndt",	"TheBigYek",	"angel_4eva",	"kr3at",	"FakejoyClothing",	"AdrianaMisoul",	"jessicahalem",	"MsVOSGES",	"johnlancia",	"mediadarwin",	"zamiang",	"FrankFay",	"victorndevries",	"Gina_Hackett",	"ikebrooker",	"TheresaFowler",	"JoeSchiappa",	"honeyberk",	"kansandhaus",	"MauriceMichael",	"RogNyc77",	"byronbrewer",	"kimdelcarmen",	"JohnExley",	"morgansteve",	"andymorris",	"KirbySaysHi",	"agobaud",	"billyboulia",	"marietta_amato",	"lucida_console",	"AdventureofDomo",	"_daniellevaldez",	"Carolsommers727",	"octane31",	"roobs83",	"CindyOlson",	"nixta",	"plingyplang",	"LoriSadel",	"gallantpresent",	"georgembodziony",	"Max_Not_Mark",	"derrickc82",	"cooper_smith",	"psilao",	"LolloPork",	"__carlo",	"nickzilla",	"jeannebopp",	"mpc100",	"mchiaviello",	"onetonnoodle",	"sm_caruso",	"ImperatorMagnus",	"nyc10016",	"olaforsstrom",	"TrevorfourEver",	"TaviB_",	"ad454",	"ericabrooke12",	"antimoshel",	"dylanschenker",	"tedgushue",	"Freakstyle1",	"ojserkisd",	"TheLeeStetson",	"MikeAdelson13",	"Myslivko",	"kjNYC",	"yawetse",	"Jetzgretz",	"SkoalDaddy13",	"uthmanbaksh",	"meganbe",	"Keiftoast",	"Lifewickedfast",	"mikelyden",	"itsAdam",	"yokevin",	"cawinemerchants",	"Rah_UniQue",	"frasian",	"mcflipper",	"JennyThunders",	"auntieclaudine",	"d0nnatr0y",	"haleighbethhh",	"GFruchtman",	"zomg_its_leah",	"morgandube",	"theJKinz",	"knowacki",	"stellar_jl319",	"elipongo",	"JamaicanmasterT",	"gabor",	"val_molina",	"Caoimhin_L",	"friskygeek",	"Dschwartz83",	"DreamboatAndie",	"tigerthedj",	"jasonschwarz",	"gmanzueta24",	"AngelEduardoC",	"ailishbot",	"SWEETnLU",	"sdavar",	"thejackamo",	"heyguey",	"SamAntar",	"SandraRipert",	"russmarshalek",	"Haylee_young",	"RafaelDiazNYC",	"FireTheCanon",	"JemAsbury",	"FilthyRockstar",	"ageciuba",	"VAJIAJIA",	"Brettabelle",	"MatthewLigotti",	"EMulvz",	"miamanhattan",	"fashion_press",	"Valdesscience",	"JohnJayinNYC",	"ys_huamani",	"doesare",	"246TiffTiff",	"Nikki_DeMarco",	"charlottenagy",	"marianne237",	"MarieDugo",	"XavierLeal18",	"aimee_sh",	"HeatherMangal",	"TTrainers",	"F_CariCortes_J",	"RachSimunovich",	"aeclearwater",	"BiggsPMF",	"kevincollier",	"LynnKatherinex3",	"rlizares",	"la_nastenka",	"amysrosenberg",	"cem3",	"EDRISSAYS",	"tteexxaass",	"amdiana",	"TCsayyys",	"KarinAraneta",	"rorydale",	"joshbarone",	"leroyjabari",	"RonnyBaroody",	"Countertenor77",	"JandyMonroe",	"norachogan",	"MJ79",	"MarquisPhifer",	"KennyKnight",	"JCSTX",	"ChadKaydo",	"GlamAiye",	"JoeyBoots",	"finitor",	"GLRobinette",	"aidenscott",	"maperencap",	"WinstonGFX",	"jessicaa_95",	"JSuk",	"amcny",	"meboudin",	"annalisacampos",	"emilygracepenn",	"zzopit",	"RedJazz43",	"JoeSaban",	"manna",	"sophiagurule",	"meaganpreyes",	"stacy_volkov",	"MrEspo",	"christiecalahan",	"kaffwinbarrett",	"rsaatian",	"patrickwesonga",	"NUJOHGNAK",	"VonMichaelnNYC",	"benjaminthigpen",	"_dbourret",	"bencashfarouq",	"JMHollister",	"_dignacio",	"glubwilsen",	"BrianHackathorn",	"KBModel",	"CoachHollywoodP",	"johnwinterman",	"RODRlCK",	"patkiernan",	"laurakazam",	"ajc6789",	"marjaruigrok",	"Mayhem4music",	"Pequody",	"PreppygirlMZ",	"amitab123",	"masmith2010",	"rutgersguy92",	"bobalcus",	"ivanit_a",	"GregBrownstein",	"BROYUMAD",	"iKhoiBui",	"nadstina",	"adonatelle",	"mstong",	"pamelavenbass",	"onacitaveoz",	"shaneeseee",	"bornreddy",	"hunterjanoff",	"zashibear",	"DoctaNYC",	"JayJohnsonLikes",	"gregchopp",	"TheGyroHero",	"ElControl24",	"KelACampbell",	"clickclash",	"charcarey",	"amyywalshh",	"shefindsjulie",	"NgawangChoney",	"ChaseRabenn",	"RadriOreamuno",	"alex55santino",	"FaridKader",	"MicheleDBeal",	"xxBang_Bang",	"molly_mcgregor",	"kcgirl2003",	"shapal26",	"MichMConnelly",	"just_teevo",	"nrocc",	"KingWilburn",	"rudyinnyc",	"johnscottreed",	"rufftooth",	"formichetti",	"aaroncoook",	"GoldJay",	"PhanieMoore",	"JeffPinilla",	"dstanks",	"leah_zara",	"Giank_M",	"John_EL",	"emjags",	"MDwightMichael",	"Kharan1",	"lindsaykos",	"TheRambling",	"Sheila_NY",	"shelbypaigeT",	"LBL4Life1",	"byronbates",	"kenspenlen",	"rockawaytrading",	"B_ronimo",	"carlipereyra",	"gd_ramirez",	"DebraBeight",	"itzikc123",	"LovesVanita",	"D_Train86",	"Danielita_C",	"Kren9",	"maebergan",	"elisesp",	"FrankKnuck",	"AlisonHeller7,AlisonVitti",	"poppyphi",	"ThisIsDansTweet",	"j2martinez",	"DelfinAlmonte",	"DJsonatra",	"ChefEvaBBQs",	"DrDaenell",	"TylerJHelms",	"xoxoDesire",	"JunkCrunk",	"EpsiloN713",	"MollyBDonovan",	"mike_ols",	"aychdee12",	"yatcher",	"lizageduldig",	"athenalove445",	"parlerfranglais",	"Anjelika_Kour",	"Aescano",	"ianwestcott",	"AMKowski11",	"JamesLKimmel",	"SimonHova",	"AnthoulaKats",	"AbieT90",	"ahil23",	"contentmode",	"bldglvr",	"DroCutz",	"celinejade_",	"iPeeWell",	"mynameisluissss",	"LaLaHearts",	"TilxDead",	"ellenmrose",	"gregb2nd",	"PRINCESSJOAN111",	"JeanaCosta",	"E_M0N3Y",	"Princessarcelay",	"deinonino",	"z4three",	"ayymaloney",	"arrejuan",	"WizbyF",	"kooldave",	"JLuuuRawr",	"BaconSeason",	"MichaelNuzzo",	"ScottRoche",	"JonMcL",	"Brandykaystarr",	"mjdwarner",	"ColleenBegley",	"missjoanzy",	"aladesnr",	"eveinthecity",	"dePlantagenet",	"alpfefs",	"harlanvaughn",	"sharlit_always",	"mikecherman",	"BarBar_Gonzalez",	"Danny_Reno27",	"Nacho_Aguayo",	"heathermaemusic",	"Tast3yMilkshake",	"sweetnycangel",	"JessicaDHughes",	"iwill_i",	"JL092479",	"ericaNAZZARO",	"GabbbCam",	"Antman73",	"darrenjmajor",	"KarinaSumano",	"DeltaWillis",	"de_stijlist",	"coreybhale",	"theSerenaGoh",	"C_It_My_Way",	"lexychik",	"WHERES___TY",	"b1g1nj4p4n",	"Caitles16",	"yourlordjason",	"TheBoken",	"Gavinluvbeyonce",	"nickbreezyyy",	"c3nki",	"hyde_jones",	"danielleleiner",	"CANKNEEMA",	"JoveMeyer",	"BrendaDevine",	"SamanVestal",	"LucaTrippitelli",	"lexigoodman",	"DrewJoseph",	"Scott_Gaffney",	"TracyStag",	"lsmael",	"ilikeredhouses",	"GibblesnBits174",	"paulbz",	"GreggTavella",	"shakatron",	"Ko0lgoSh",	"ACPressLee",	"Jon_Lazo",	"jaimedavalos",	"itrosky",	"FoxyQuant",	"Quacks12",	"jorgiecakes",	"hyperjetlag",	"JUSTmeALISEO",	"dudeguywhyyy",	"marxsismo",	"cara_bloch",	"RichBranding",	"xiehan",	"DaFrEsHoNeX",	"McSassy86",	"GodsFetus",	"Kucmyda",	"NickHarvin",	"JaeSelle",	"schenwow",	"THEMISSHAPES",	"KadeySisselman",	"BxMixPapii90",	"BklynBeauty_718",	"txcoonz",	"Killer62",	"ArnellMilton",	"KaliPorteous",	"tessa",	"GreyEraVintage",	"MaddManEd",	"AwkwardChef",	"MikeDosPhoto",	"turrneygeeHAHA",	"cheyennesantoro",	"RealMaxWilder",	"neiled",	"HellerJack",	"amyinbiz",	"KenKoc1",	"MichielPenne",	"mbytz",	"FernandaNuez10",	"taylorrayh",	"BreezeThroughIt",	"OMGItssJadee",	"MikeMontyy",	"HauteTalk",	"lindsaymayphoto",	"BradenBert",	"SeanG45",	"SH_Lynch",	"getraddielater",	"mattphadams",	"lydialauer",	"Amandahurn",	"AXTONFRICK",	"jmnzzkr",	"BennyBangBang",	"iluvprincetonxo",	"brian_perks",	"lexydubicki",	"AmberAAlonzo",	"MasterJao",	"djclsmooth",	"ElCrupi",	"teaforpaige",	"MikePitsikoulis",	"Steph_M_Rod",	"DomC_",	"EricaLynnYoung",	"aceytoso_2",	"anneeoanneo",	"Joeythefox323",	"Tiffers002",	"Kahahate",	"Rivkind",	"taaramariie",	"AmandaWehnke",	"Baksissa",	"DamianDazz",	"mnapoli765",	"sdadich",	"Vbrancato31",	"KiiddPhenom",	"BleedBlue0415",	"ByronBradshaw",	"KatieeeO",	"justinography",	"petemall",	"Hewitt_Ray",	"YourScheid",	"diamondz_shine",	"heather_joness",	"cristina8pineda",	"amirkaz",	"natefrench18",	"fuglyslaut",	"PinsiLei",	"workfreelyblog",	"Omg_itsjt1",	"leahcamp17",	"Wendizille",	"sprocops",	"vcmcmullen",	"janeeCouture",	"NikkiBogopo",	"KHarveynyc",	"bielparklee",	"SaganSabri",	"0neMOtime",	"yamile_b",	"berrytori",	"c_s_tattoo",	"Smashlosays",	"TayloorKirsch",	"evankonwiser",	"marotin507",	"Paige0830",	"LauMc822",	"bia_mur",	"DaReal_JrJones",	"BullGatorMikeA",	"hiren1012",	"NolanAFox",	"bk_Jonni",	"majabruha",	"JulieBean13",	"SarahLuttinger",	"JakeEverdean",	"rydoyylee",	"wisecraxx",	"krystina_erin",	"MrSince86",	"Sara_Persiano",	"themidwestgirl",	"CapriMcQueen",	"Zach_Massari10",	"SOBRENATURAL7",	"CapponiWho",	"squish108",	"CluelessMaven",	"_ramopxela",	"Tabanid_Tink",	"marko0318",	"JeSuisJaymeee",	"RealJMac247",	"sparkdiana",	"DavidLinnNY",	"Sarahjnj",	"allybmartin",	"seonbarbera",	"acwelch",	"KatieLusso",	"Lexi1021",	"LondonInNY",	"nataliecantell",	"RsilverfoxR",	"kaliswa",	"mattgunn",	"lizsetton",	"livinbreezy",	"Hughley45",	"DanialvarezPR",	"bryanthatcher",	"Reneeheartsnyc",	"MDCSpace",	"hyevinkim",	"DinaMarie8",	"BrittKnee86",	"like_the_soup",	"lilDeVos",	"eeducin",	"EJHarnois",	"KurtDelleDonne",	"PatricksBeer",	"suzyscott715",	"laslugocki",	"filanagee",	"mediajorge",	"ToastSolo",	"brooklynivystar",	"Jelosy14a",	"Natalieeinnyc",	"TerriYee",	"MurrayDweck",	"SaeedAMahmood",	"ashleymchandler",	"jcm_mejia91",	"AmandaStilts",	"CharlieF03",	"JDfromUGC",	"JOAODEMATOSNYC",	"allii_95",	"MexSunrise",	"YungRecklessFun",	"JeanAracena",	"PainFresh6",	"jhelmus",	"jsjohnst",	"nycdain",	"oliviawhatsup",	"meriSsy_joy",	"nicole_edwards4",	"soulellis",	"AH_Ethan",	"jennylubkin",	"keniehuber",	"T_Hill18",	"anisa_hodzic",	"joyellenicole",	"CJ_GIST",	"pinkishhoodie",	"hannahward89",	"ManhattanzElite",	"Jokashyola",	"ajb613",	"Ariadnasandy_1D",	"grant_henning",	"stepliana",	"MiZzMyRa",	"tommorton",	"personalitini",	"Jerry_Sandoval",	"BillyCordova7",	"AMEDEONYC",	"shu_rosaline",	"Roze_316",	"breecookiee",	"DevenMcCarthy",	"GaryAlonyNYC",	"p00nie",	"marysecondo",	"kikiboyle",	"PrinceRoger",	"Anathebartender",	"b_m0ney",	"JamesKiernan",	"ncbii",	"RickiSofer",	"gabesantacruz10",	"ShawnieMikes",	"RichellaBella",	"cherishj82",	"noneck",	"noobsbt",	"legsfordaysss",	"plrodriguez",	"Galetome",	"forero29",	"howodd",	"christiansmythe",	"untulis",	"KBopf",	"AshleyMKearns",	"BreanneSpainhow",	"b_mazzz",	"Jaclyn_Desi",	"LucaMazzo24",	"totivaldez",	"ELREYSOYYO_",	"rocco",	"mch710",	"mavraganis",	"geoylee",	"MrsPuertoRico",	"MIVenuto",	"adiesaurus",	"taniafs921",	"rollingturtle",	"sofia_esnaola,Sofia_Esnaola",	"conrad",	"compa_tijero",	"AndreaEPalesh",	"Christie_Jenna",	"lahufj",	"OneJason",	"DDSethi",	"cassanova13",	"UncLonghorn",	"LenaDoloKersh",	"FrancesOjalvo",	"JamesMarotta_",	"taftcard",	"StephanieBorak",	"noreanc",	"JesseCFriedman",	"DennisVera",	"arimwhite",	"Robrogan",	"healysnow",	"petroleumj",	"Lobomundo",	"MeghannBWright",	"azaay95",	"stevewax",	"KaeMitch",	"ECava",	"johnsto",	"natalie_olsen",	"luisfglz",	"MarleeGreenberg",	"jasonwhat",	"sandelestepan",	"kriistinax33",	"plastic_bear",	"cetinok",	"andrewcroke21",	"Tofiquee",	"lolnikitaa",	"TAY_125_",	"aimerlaterre",	"Madein24K",	"jedi_jjo",	"Trimarchi023",	"lykeleia",	"EffinwitESH",	"plaidsandwich",	"JoshTPIY",	"KonstantDuke",	"JoeeSmith19",	"madamelolo",	"Mitsue719",	"gypsieeyez35",	"GregMason82",	"btreglio",	"Jrfarina",	"iamchrisbarlow",	"brucknerchase",	"whitneymeers",	"bestiecilla",	"davidsigal",	"NickeyyDees",	"waynegblum",	"arojass",	"inthewordsofkim",	"Jimmy5wagga",	"lahappybelle",	"jaimieS23",	"brandontonio",	"JillianLGreen"]

#users_for_kevin.sort!

users_for_ncar_test = ["Tocororo1931","Leslie_reilly","kr3at","marietta_amato","haleighbethhh","morgandube","Nikki_DeMarco","rutgersguy92","aidenscott","RedJazz43","onacitaveoz","just_teevo","leah_zara","D_Train86","Kren9","DJsonatra","mynameisluissss","JL092479","Antman73","Caitles16","danielleleiner","Scott_Gaffney","ericaNAZZARO","txcoonz","KaliPorteous","OMGItssJadee","jmnzzkr","AmberAAlonzo","DomC_","mnapoli765","BleedBlue0415","TayloorKirsch","Zach_Massari10","CluelessMaven","PainFresh6","Roze_316","DevenMcCarthy","Anathebartender","forero29","KBopf","b_mazzz","Christie_Jenna","DDSethi","stevewax","JoeeSmith19","iKhoiBui","Sara_Persiano"]

users_for_ncar_test.sort.each_with_index do |user_handle, index|

	#Important that we don't keep the cursor open because the timeout apparently doesn't work....
	user = Twitterer.where(:handle => user_handle).first

	puts "\nProcessing: #{user.handle} with #{user.tweet_count} geo coded tweets"

	user_content = {	"GeoCoded Tweet Count"    => user.tweet_count,
						"Unclassified Percentage" => user.unclustered_percentage,
						:tweets=>[]
					}


	#If contextual_stream is defined, then it'll grab the contextual stream, otherwise just hit DB
	if contextual_stream.nil?
		user.tweets.each do |tweet|
    		user_content[:tweets] << {:Date => tweet.date, :Text => tweet.text, :Coordinates=>tweet.coordinates["coordinates"]}
  		end
  	else
		user_content[:tweets] = contextual_stream.get_full_stream(user.tweets.first.handle)
	end
	
	unless user_content[:tweets].empty? #There's the chance it isn't found, which is bad.
		
		user_content[:tweets] = user_content[:tweets].sort_by{|tweet| tweet[:Date]}

		user_content["Total Tweets Here"] = user_content[:tweets].count

		kml_link = "kml_files/#{user.sanitized_handle}.kml"

		# #======================================================================
		#Lets write a KML file for this user.
		kml_outfile = EpicGeo::Writers::KML::KMLAuthor.new("NJ_UsersToCode/kml_files/#{user.sanitized_handle}.kml")
		kml_outfile.write_header("KML Visualized file for #{user.handle}")
		write_3_bin_styles(kml_outfile.openfile)

		#Clusters
		base_cluster  = user.cluster_locations[user.base_cluster.to_s]
		storm_cluster = user.cluster_locations[user.during_storm_cluster.to_s]
		
		# points_of_interest = {:name=>"User Clusters", :features=>[]}
		# points_of_interest[:features] << point_as_epic_kml(
		# 	"Base Cluster",
		# 	base_cluster[0],
		# 	base_cluster[1],
		# 	style="before")

		# points_of_interest[:features] << point_as_epic_kml(
		# 	"During Storm Cluster",
		# 	storm_cluster[0],
		# 	storm_cluster[1],
		# 	style="during")

		#Add all of their tweets
		tweets = {:name=>"Tweets", :features=>[]}
		user.tweets.each do |tweet|
			if tweet.date > _start and tweet.date < _end
				tweets[:features] << tweet.as_epic_kml(style=nil)
			end
		end

		user_folder = {:name=>user.sanitized_handle, :features=>[], :folders=> [tweets]}#, points_of_interest]}

		kml_outfile.write_folder(user_folder)
		kml_outfile.write_footer
		# #=====================================================================





		#Add the user to a web archive for sharable, easy viewing
		# =======================================================
		web_archive.add_user_page(user.sanitized_handle, user_content, kml_link)
		

		# #Add the user to the Google Spreadsheet
		# #======================================
		user_sheet = wb.add_worksheet(title: user.handle, headers: coding_sheet_headers)
		user_content[:tweets].each_with_index do |tweet|
			user_sheet.add_tweet(tweet)
		end
		if ((index+1)%16).zero?
			puts "------Writing new Workbook------"
			sheets_count +=1
			wb = EpicGeo::Writers::GoogleDrive::SheetMaker.new(
				collection: "CollapsedCodingSample",
				name: 		"CollapsedCodingSampleUsers-#{sheets_count}"
			)
		end
		#=========================================
	end
end

#Closing Functions
web_archive.write_index