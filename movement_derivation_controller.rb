#= Main Controller for Twitter Evacuation Pattern Work
#
#put an arugment parser here for the main runtime?

#Enable relative loading of any file
$:.unshift File.dirname(__FILE__)


# Set Modules to be autoloaded, if necessary
autoload :ContextualStream, 'modules/contextual_stream'
autoload :CustomFunctions,  'modules/functions'
autoload :TimeProcessing,   'modules/time_processing'


class TwitterMovementDerivation

  require 'time'

  attr_reader :environment, :database, :port, :server, :factory

  def initialize(args)
    @environment = args[:environment] || 'local'
    @server      = args[:server]      || 'localhost'
    @database    = args[:database]    || 'sandygeo2'
    @port        = args[:port]        || 27017
    @factory     = args[:factory]     || 'local'
    puts "Initializing Twitter Movement Derivation: #{environment}"
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

    #Now we can call Mongo Mapper, because the Gemfile allows it
    require 'mongo_mapper'

    #Require our Twitterer Model, this loads super class and tweets
    require_relative 'models/twitterer'

    #Connect to the database
    MongoMapper.connection = Mongo::Connection.new(server, port)
    MongoMapper.database = database

    if args[:factory] == 'local'
      @factory = RGeo::Geographic.projected_factory(projection_proj4: '+proj=utm +zone=18 +datum=NAD27 +units=m +no_defs ')
    else
      @factory = RGeo::Geographic.simple_mercator_factory #The basic factory for web mercator data; anything but 'local'
    end
  end

  def setup_server(args)
    #Require these further gems to make everything work on the server
    require 'active_support'
    require 'active_support/deprecation'
    require 'epic_geo'
  end

  def force_reload
    load 'models/twitterer'
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
  env = ARGV[0] || 'local'
  runtime = TwitterMovementDerivation.new(
    environment: env
  )
end
