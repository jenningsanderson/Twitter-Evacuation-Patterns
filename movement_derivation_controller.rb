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
    @environment = args[:environment].to_sym || :local
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
  geo  = ARGV[1] || 'gem'
  runtime = TwitterMovementDerivation.new(
    environment: env,
    geo: geo,
    factory: 'global'
  )

  res = Twitterer.where(unclustered_percentage: nil).limit(1000)

  res.each_with_index do |user, idx|
    unless user.tweets.count == 0
      puts user.handle, idx
      puts "Calling Cluster"
      user.process_tweets_to_clusters
      puts "Finished Cluster"
      user.save
    end
  end

end
