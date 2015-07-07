#Ensure we're using the correct version of the gems
require 'rubygems'
require 'bundler/setup'
require 'parallel'

env  = ARGV[0] || 'serverlocal'
geo  = ARGV[1] || 'gem'
LIMIT   = 100
PROCESSES = (ARGV[2] || '2').to_i

alpha = ['0','1','2','3','4','5','6','7','8','9','r','s','t','u','v','w','x','y','z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q']

coded_users =  ["GinaBoop21", "4thFloorWalkUp", "acbrush", "1903barisdamci", "aalhaider84", "977wctyJesse", "D_AGOSTINO", "AdieMeshel", "rcrocetti", "acdm", "onacitaveoz", "ccompitiello", "3ltutuykt", "2fritters", "502BIGBLOCK", "JFranxMon", "aby_orozco", "246TiffTiff", "nikkovision", "acdcrocker94", "forero29", "txcoonz", "voudonchilde", "adiesaurus", "abestt", "aaronlugo20", "yogabeth218", "AdamBroitman", "compa_tijero", "37kyle", "12CornersNYC", "ABerneche11", "hatchedit", "aanniemal", "ryryrocketss", "AbdulazizSadeq", "JoeeSmith19", "acordingley", "a13xandraaaa", "WaitingQueen", "danielleleiner", "abr74", "92Hughes92", "brittlizarda", "33amelie", "aidenscott", "5pointbuck", "aceytoso_2", "TravissGraham", "Nikki_DeMarco", "haleyybreen", "abrackin", "DDSethi", "haleighbethhh", "Mac_DA_45", "40Visionz", "b_mazzz", "132Sunshine", "1stFITNESSMC", "CluelessMaven", "adel1196", "aaziz830", "adawood30", "DbLeonor", "bakedtofu", "ActualyAmGeorge", "AdamVanBavel", "workfreelyblog", "HarriBoiii", "brieeellee", "AndeLund", "1Vincent", "Zach_Massari10", "Roze_316", "RedJazz43", "1xr650guy", "lizeeSuX", "4everSeductive", "AmberAAlonzo", "Kessel_Erich2", "adamebnit", "PainFresh6", "according2Drew", "Tyler_Mayer", "Sara_Persiano", "adampdouglas", "ACPressLee", "AdamHedenskog", "Caitles16", "adonatelle", "DJsonatra", "Scott_Gaffney", "GrooDs", "acwelch", "just_teevo", "mynameisluissss", "kcgirl2003"]

res = Parallel.map(coded_users) do |letter|
  #
  # Make a new everything for this process; then perhaps even split this into further threads?
  #
  require_relative '../movement_derivation_controller'
  runtime = TwitterMovementDerivation.new(
    environment: env,
    geo: geo,
    factory: 'global'
  )
  puts "Starting Process: #{letter}"
  Twitterer.where(unclustered_percentage: nil, handle: /^#{letter}/).limit(LIMIT).each do |user|
    unless user.tweets.count == 0
      puts user.handle
      begin
        user.process_tweets_to_clusters
        user.save
      rescue => e
        puts "Something bad happened on #{user.handle}"
        next
      end
      puts "-------FINISHED #{user.handle}-----------"
    end
  end
end
