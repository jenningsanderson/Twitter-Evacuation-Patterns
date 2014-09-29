# GeoJSON Export
#
# Write a GeoJSON file
#

require 'mongo_mapper'
require 'epic-geo'

require_relative '../models/twitterer'
require_relative '../models/tweet'

filename = "mid_precision_evac"
limit = nil

#Prepare a GeoJSON file

geojson_outfile = GeoJSONWriter.new("../exports/#{filename}")
geojson_outfile.write_header

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'


max_precision_users = ["dogukanbiyik","kimdelcarmen","rchieB","fernanjos","nicolelmancini","Krazysoto","ailishbot","CharisseCrammer","jericajazz","KD804","jesssgilligan","theJKinz","TheAwesomeMom","bjacksrevenge","jefflac","roobs83","jds2001","SimoMarms","NYCGreenmarkets","c3nki","MoazaMatar","KiiddPhenom","sandelestepan","tlal2","BeachyisPeachy","cyantifik","FrankKnuck","mattgunn","Max_Not_Mark","JaclynPatrice","Rigo7x","ajc6789","yagoSMASH","polinchock","indavewetrust","CillaCindaplc2B","Javy_Jaz","eric13000","becaubs","enriqueskincare","Rivkind","janelles__world","CoreyKelly","josalazas","CapponiWho","JohnBakalian1","valcristdk","forero29","BobGrotz","CodyRodrigu3z","CoastalArtists","VSindha"]

users = ["dogukanbiyik","AthenaPetro","urifintzy","JMWEIN01","AreaKhodes","masmith2010","JackiReisinger","SalimKuri","curvyinthecity","marissa_merola","THEMISSHAPES","omgloletcetc","vssecrets","CALLMEBLONDY","RealJMac247","PeterVAmador","SarahLuttinger","KatieLusso","Hughley45","AdamRHarrington","flu","NITSUJG","mlaurencell","kimdelcarmen","TimColeman_9","deepenuff","tommyohandsome","jpaoletti22","gutoedalcoquio","SierraMist10","TheGrooveRadio","rchieB","fernanjos","JamesLKimmel","avianarior","nicolelmancini","JanelleChanel","Krazysoto","blancobeboostin","io_waters","ikebrooker","MrAgard","ashhast","YalitzaRuiz","AlexBerdoff","christiansmythe","julietbrownn","BreanneSpainhow","CianiKae","cookcolleen","ailishbot","thesafariman","nlprince","Lauren_Morra","anneeoanneo","noey_neums","JRodriguez0403","CharisseCrammer","ojserkisd","marietta_amato","NgawangChoney","jericajazz","GrahamCC","yamile_b","KD804","jsscrhhhh","fcogian","Luvume1","maperencap","jesssgilligan","georgegosson","adamewoods","CoachMichi","jaypinho","carlfranzen","andreanpardo","JIbanezM","life_savour","gallantpresent","aamador116","taniaelopez","theJKinz","DrewESCAPE","TheAwesomeMom","ClaudiaRv","JennyThunders","marcos1980nj","NicholasPClarke","_tammie","justdizle","jaycsanch","bjacksrevenge","JimFishIII","KernsKadie","jefflac","uthmanbaksh","TheresaFowler","amyy_duh","rvillacarillo","jamesmagenst","suzyscott715","ashleenicole_05","victorndevries","joerodr","emily_maffetone","lynncasper","roobs83","torrduer","jds2001","Lord_Horatio","SimoMarms","HIHEELZbrooke","NYCGreenmarkets","Luzaic","MisterLaMasa","c3nki","OhOhOhItsJoHnNy","nealrs","Krlanham","MoazaMatar","Fall_on_jimmy","Robbajor","alexxxengland","ayumitakashi","lisuhc","MadalynPinto","MarquisPhifer","chinatheperson","gaviino14","lessgasper1","redfabbri","KiiddPhenom","Fr33_Money","Rednecksarah72","Vbrancato31","violinrose","VAJIAJIA","KonstantDuke","JLuuuRawr","CHULYAKOVDESIGN","hubertsdik10","Dwall562","NYcep3","vivalaglam7","m0eDizZy","CeaseTheDay","sandelestepan","Brit_Kotary","TilxDead","allurahipper","CiCiBarton","johnspinks","Sumvitg76","Dboonoggle","baratunde","tlal2","BeachyisPeachy","tristanalton","numberednoise","Chris_OTF","jacquelinenovak","cyantifik","xojenn48ox","cmj5112000","zombiefightere","mhcoops18","FrankKnuck","isiselin","JamilMangan","fcollins53","just_teevo","belmardays","mattgunn","saraehalper","Max_Not_Mark","beccasaraga","ericabrooke12","MicheleLaudig","DjMikeTouch","fredstardagreat","rockawaytrading","BrittDisneyMom","HollyFabs","DrJonesIIIESQ","KatherineLudwig","PhanieMoore","JaclynPatrice","julinedelucci","gmanzueta24","MikeTRose","aeclearwater","Rigo7x","Mr_Rivs15","WinstonGFX","RedJazz43","ajc6789","JayJohnsonLikes","yagoSMASH","polinchock","indavewetrust","JohnDeMarzo","MDwightMichael","CillaCindaplc2B","pabanclara","erinl0vesyouu","Electric__Jesus","Taz_M86","ScottRoche","Javy_Jaz","HannahGraceS","dmurrr","TheFashionGrad","dancinfeet83","eric13000","becaubs","DaniDur","NuevaVaina","lianawrightmark","Kellybrownizzle","JaeSelle","Kr1stine_","HitzProductions","chelseaaa_xO","enriqueskincare","AmberAAlonzo","Formula1gyrl","Rivkind","janelles__world","MissBergdorf","sutherland4l","CoreyKelly","alexandraalida","_danieljames_","BleedBlue0415","vcmcmullen","josalazas","shitcharleysays","hiren1012","WhoDat21625","CapponiWho","JohnBakalian1","CluelessMaven","JeSuisJaymeee","RicardoJSalazar","like_the_soup","NickGagliano16","valcristdk","forero29","TomAlm","h0h0h0","rocco","arimwhite","ny_emilyolivia","aimerlaterre","Liviosah","BobGrotz","PursuitofNY","jenastelli","memoirs_ofmilla","hollygirl358","shefinds","johndeguzman","jengrunwald","JessHaberman","gii_mariie","CatherineNBarde","CodyRodrigu3z","wisej05","Kytheman132","theREALNickPang","ITzSmak","Tymarcy","_SammyShay","wrandallgoodwin","TapDanceKaz","eslat82","mariannemurph","Anna___Riley","CoastalArtists","aaretz","VSindha","jvwong96","ATalasnikCSN","damageathletics","MartenRobert","ximena_d","alsfid","ChristieKemper"]

results = Twitterer.where(
                :handle.in => max_precision_users
              ).limit(limit)

puts "Query found #{results.count} users"

results.each do |user|

  print "Processing User: #{user.handle}..."

  geometry = {:type => "Point", :coordinates => user.cluster_locations[:before_home]}
  properties = {:handle => user.handle, :sip_conf => user.sip_conf, :evac_conf => user.evac_conf}

  geojson_outfile.write_feature(geometry, properties)

end

geojson_outfile.write_footer
