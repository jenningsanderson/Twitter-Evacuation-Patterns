#First, create the runtime
require_relative '../movement_derivation_controller.rb'

runner = TwitterMovementDerivation.new(
  environment: 'processing',
  geo: 'gem',
  factory: 'global',
  base_path: '/home/jennings/Twitter-Evacuation-Patterns'
)

context = ContextualStream::ContextualStreamRetriever.new(
  root_path: '/home/kena/geo_user_collection/'
)

coded_users =  ["GinaBoop21", "4thFloorWalkUp", "acbrush", "1903barisdamci", "aalhaider84", "977wctyJesse", "D_AGOSTINO", "AdieMeshel", "rcrocetti", "acdm", "onacitaveoz", "ccompitiello", "3ltutuykt", "2fritters", "502BIGBLOCK", "JFranxMon", "aby_orozco", "246TiffTiff", "nikkovision", "acdcrocker94", "forero29", "txcoonz", "voudonchilde", "adiesaurus", "abestt", "aaronlugo20", "yogabeth218", "AdamBroitman", "compa_tijero", "37kyle", "12CornersNYC", "ABerneche11", "hatchedit", "aanniemal", "ryryrocketss", "AbdulazizSadeq", "JoeeSmith19", "acordingley", "a13xandraaaa", "WaitingQueen", "danielleleiner", "abr74", "92Hughes92", "brittlizarda", "33amelie", "aidenscott", "5pointbuck", "aceytoso_2", "TravissGraham", "Nikki_DeMarco", "haleyybreen", "abrackin", "DDSethi", "haleighbethhh", "Mac_DA_45", "40Visionz", "b_mazzz", "132Sunshine", "1stFITNESSMC", "CluelessMaven", "adel1196", "aaziz830", "adawood30", "DbLeonor", "bakedtofu", "ActualyAmGeorge", "AdamVanBavel", "workfreelyblog", "HarriBoiii", "brieeellee", "AndeLund", "1Vincent", "Zach_Massari10", "Roze_316", "RedJazz43", "1xr650guy", "lizeeSuX", "4everSeductive", "AmberAAlonzo", "Kessel_Erich2", "adamebnit", "PainFresh6", "according2Drew", "Tyler_Mayer", "Sara_Persiano", "adampdouglas", "ACPressLee", "AdamHedenskog", "Caitles16", "adonatelle", "DJsonatra", "Scott_Gaffney", "GrooDs", "acwelch", "just_teevo", "mynameisluissss", "kcgirl2003"]
coded_users.map!{|x| x.downcase}


errors = File.open('tweet_source_import_errorlog.txt','wb')


puts "Accessing Twitterers collection, count: #{Twitterer.count}"
res = Twitterer.where(handle: {'$in'=> coded_users}).limit(5)
puts "Found #{ res.count() } users"

res.each do |user|

  handle = user.handle
  #First, get the user_id
  context.set_file_path(handle)

  all_tweets = context.get_full_stream(geo_only=true)

  all_tweets.each_with_index do |t, idx|
    this_t = user.tweets[idx]
    if this_t.id_str = t[:Id]
      puts "match!"
    else
      puts "error!"
    end
  end
end

errors.close()
