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

  attr_reader :environment, :database, :port, :server, :factory

  def initialize(args)
    @environment = args[:environment].to_sym || :local
    @factory     = args[:factory]            || 'local'
    puts "Initializing Twitter Movement Derivation envrionment: #{environment}"
    post_initialize(args)
  end

  def post_initialize(args)
    #Use the bundler to ensure we get all the dependencies met
    require 'rubygems'
    require 'bundler/setup'

    #This sets up the environments
    if environment == 'server'
      setup_server(args)
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

  def setup_server(args)
    #Require these further gems to make everything work on the server
    require 'active_support'
    require 'active_support/deprecation'
    require 'epic_geo'
  end

  def force_reload
    load 'models/twitterer.rb'
  end

  #Global Variables
  TIMES = {
  	event: 		  Date.new(2012,10,29),
  	two_days:   Date.new(2012,10,31),
  	one_week: 	Date.new(2012,11,7)
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
  host = ARGV[1] || 'localhost'
  runtime = TwitterMovementDerivation.new(
    environment: env,
    server: host,
    factory: 'global'
  )

  res = Twitterer.where(unclustered_percentage: nil).limit(1000)

  res.each_with_index do |user, idx|
    unless user.tweets.count == 0
      puts user.handle, idx
      user.process_tweets_to_clusters
      user.save
    end
  end

end
