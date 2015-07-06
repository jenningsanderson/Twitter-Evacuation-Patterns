require_relative '../movement_derivation_controller.rb'
include CustomFunctions
require 'csv'

if __FILE__ == $0
  env  = ARGV[0] || 'processing'
  geo  = ARGV[1] || 'local'
  runtime = TwitterMovementDerivation.new(
    environment: env,
    geo: geo,
    factory: :local
  )

  coded_users =  ["GinaBoop21", "4thFloorWalkUp", "acbrush", "1903barisdamci", "aalhaider84", "977wctyJesse", "D_AGOSTINO", "AdieMeshel", "rcrocetti", "acdm", "onacitaveoz", "ccompitiello", "3ltutuykt", "2fritters", "502BIGBLOCK", "JFranxMon", "aby_orozco", "246TiffTiff", "nikkovision", "acdcrocker94", "forero29", "txcoonz", "voudonchilde", "adiesaurus", "abestt", "aaronlugo20", "yogabeth218", "AdamBroitman", "compa_tijero", "37kyle", "12CornersNYC", "ABerneche11", "hatchedit", "aanniemal", "ryryrocketss", "AbdulazizSadeq", "JoeeSmith19", "acordingley", "a13xandraaaa", "WaitingQueen", "danielleleiner", "abr74", "92Hughes92", "brittlizarda", "33amelie", "aidenscott", "5pointbuck", "aceytoso_2", "TravissGraham", "Nikki_DeMarco", "haleyybreen", "abrackin", "DDSethi", "haleighbethhh", "Mac_DA_45", "40Visionz", "b_mazzz", "132Sunshine", "1stFITNESSMC", "CluelessMaven", "adel1196", "aaziz830", "adawood30", "DbLeonor", "bakedtofu", "ActualyAmGeorge", "AdamVanBavel", "workfreelyblog", "HarriBoiii", "brieeellee", "AndeLund", "1Vincent", "Zach_Massari10", "Roze_316", "RedJazz43", "1xr650guy", "lizeeSuX", "4everSeductive", "AmberAAlonzo", "Kessel_Erich2", "adamebnit", "PainFresh6", "according2Drew", "Tyler_Mayer", "Sara_Persiano", "adampdouglas", "ACPressLee", "AdamHedenskog", "Caitles16", "adonatelle", "DJsonatra", "Scott_Gaffney", "GrooDs", "acwelch", "just_teevo", "mynameisluissss", "kcgirl2003"]

  res = Twitterer.where(handle: {"$in" => coded_users.collect{|x| x.downcase} })

  res.each do |user|
    puts user.handle
    File.write "assets/geojson/coded_users/#{user.handle}.geojson", user.tweets_to_geojson($times[:one_week_before], $times[:one_week_after])
  end

# CSV.open('/tmp/coded_users_movement.csv','wb') do |csv|
    # res.each do |user|
    #   puts user.handle
    #
    #   #This next section looks at the tweets in the relevant two weeks and builds a relative movement profile
    #   user_clusters = []
    #   ($times[:one_week_before]..$times[:one_week_after]).each do |day|
    #     clusters = []
    #     user.time_bounded_tweets(day, day+1).each do |t|
    #       clusters << t.cluster_id
    #     end
    #     c = nil
    #     c = mode(clusters) unless mode(clusters)=="-1"
    #     if c.nil?
    #       user_clusters << 0
    #     else
    #       user_clusters << $factory.point(user.cluster_locations[c][0],user.cluster_locations[c][1])
    #     end
    #   end
    #   movement = []
    #   (0..user_clusters.length-2).each do |idx|
    #     if user_clusters[idx]==0 or user_clusters[idx+1]==0
    #       movement << -1
    #     else
    #       movement << user_clusters[idx].distance(user_clusters[idx+1])/1000
    #     end
    #   end

      # csv << [user.handle] + movement
      # movement[] is a list of relative distances between clusters per day. Perhaps it should be relative to
      #  the home location?
      # user.rel_movement = movement
      # user.save
    # end
  # end
end
