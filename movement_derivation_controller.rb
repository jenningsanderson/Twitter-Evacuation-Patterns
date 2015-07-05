#Enable relative loading of any file
$:.unshift File.dirname(__FILE__)


# Set Modules to be autoloaded, if necessary
autoload :ContextualStream, 'modules/contextual_stream'
autoload :CustomFunctions,  'modules/functions'
autoload :TimeProcessing,   'modules/time_processing'

#= Main Controller for Twitter Evacuation Pattern Work
#
class TwitterMovementDerivation

  require 'time'

  attr_reader :environment, :database, :port, :server, :factory, :geo

  def initialize(args)
    @environment = args[:environment].to_sym || :serverlocal
    @geo         = args[:geo].to_sym         || :gem
    @factory     = args[:factory]            || 'local'
    puts "Initializing Twitter Movement Derivation environment: #{environment}"
    post_initialize(args)
  end

  def post_initialize(args)
    #Use the bundler to ensure we get all the dependencies met
    require 'rubygems'
    require 'bundler/setup'

    if geo == :gem
      require 'epic_geo'
    else
      require_relative '/Users/jenningsanderson/Documents/epic-geo/lib/epic_geo.rb'
    end

    require 'mongoid'
    Mongoid.load!('persistence/mongoid.yml', environment)

    require 'models/twitterer'

    if factory == 'local'
      $fatory = RGeo::Geographic.projected_factory(projection_proj4: '+proj=utm +zone=18 +datum=NAD27 +units=m +no_defs ')
    else
      $factory = RGeo::Geographic.simple_mercator_factory #The basic factory for web mercator data
    end
  end

  def force_reload
    load 'models/twitterer.rb'
  end

  #Global Variables
  $times = {
    one_week_before:  Date.new(2012,10,22),
    two_days_before:  Date.new(2012,10,27),
  	landfall: 		    Date.new(2012,10,29),
  	two_day_afters:   Date.new(2012,10,31),
  	one_week_after: 	Date.new(2012,11,7)
  }

  #Deprecated, will update
  RISK_LEVELS = {
  	10 	=> 	"NYC Zone A",
  	11 	=> 	"NYC Zone B",
  	12 	=> 	"NYC Zone C",
  	20 	=> 	"NJ Barrier Coast",
  	50 	=> 	"NCAR Bounding Box",
  	100 => 	"Outside NCAR Bounding Box"
  }
end

if __FILE__ == $0
  env  = ARGV[0] || 'local'
  geo  = ARGV[1] || 'gem'
  runtime = TwitterMovementDerivation.new(
    environment: env,
    geo: geo,
    factory: 'global'
  )

  coded_users =  ["GinaBoop21", "4thFloorWalkUp", "acbrush", "1903barisdamci", "aalhaider84", "977wctyJesse", "D_AGOSTINO", "AdieMeshel", "rcrocetti", "acdm", "onacitaveoz", "ccompitiello", "3ltutuykt", "2fritters", "502BIGBLOCK", "JFranxMon", "aby_orozco", "246TiffTiff", "nikkovision", "acdcrocker94", "forero29", "txcoonz", "voudonchilde", "adiesaurus", "abestt", "aaronlugo20", "yogabeth218", "AdamBroitman", "compa_tijero", "37kyle", "12CornersNYC", "ABerneche11", "hatchedit", "aanniemal", "ryryrocketss", "AbdulazizSadeq", "JoeeSmith19", "acordingley", "a13xandraaaa", "WaitingQueen", "danielleleiner", "abr74", "92Hughes92", "brittlizarda", "33amelie", "aidenscott", "5pointbuck", "aceytoso_2", "TravissGraham", "Nikki_DeMarco", "haleyybreen", "abrackin", "DDSethi", "haleighbethhh", "Mac_DA_45", "40Visionz", "b_mazzz", "132Sunshine", "1stFITNESSMC", "CluelessMaven", "adel1196", "aaziz830", "adawood30", "DbLeonor", "bakedtofu", "ActualyAmGeorge", "AdamVanBavel", "workfreelyblog", "HarriBoiii", "brieeellee", "AndeLund", "1Vincent", "Zach_Massari10", "Roze_316", "RedJazz43", "1xr650guy", "lizeeSuX", "4everSeductive", "AmberAAlonzo", "Kessel_Erich2", "adamebnit", "PainFresh6", "according2Drew", "Tyler_Mayer", "Sara_Persiano", "adampdouglas", "ACPressLee", "AdamHedenskog", "Caitles16", "adonatelle", "DJsonatra", "Scott_Gaffney", "GrooDs", "acwelch", "just_teevo", "mynameisluissss", "kcgirl2003"]


  coded_users.each do |user|
    user.downcase!
    res = Twitterer.where(handle: user)
    if res.count < 1
      puts "Can't find: #{user}"
    end
  end

  # res = Twitterer.where(unclustered_percentage: {'$lt' => 50, '$gt' => 0}).limit(10)
  # res = Twitterer.where(handle: {"$in" => coded_users.collect{|x| x.downcase} })

  # puts res.count

  # res.each_with_index do |user, idx|
  #   puts user.handle
  #   puts user.clusters.length
  #   puts user.during_storm_clusters.length
  #   # user.cluster_locations_as_geojson
  #   # File.write("/tmp/#{user.handle}.geojson", user.cluster_locations_as_geojson.to_json)
  # end

end
