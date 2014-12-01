Evacuation & Migration Prediction through Twitter Analysis
==========================================================

Jennings Anderson, Marina Kogan, Kevin Stowe @ [Project EPIC](http://epic.cs.colorado.edu)

_This is the continuation of a project first started in GIS3 in Spring 2014 at CU Boulder by Jennings Anderson, Andrew Hardin, Ellie Falletta_

##Motivation
Somewhere on order of 1% of tweets are geo-tagged.  What can be learned about a Twitterer's movement behavior during Hurricane Sandy?

##Ruby Dependencies
	gem install georuby
	gem install rgeo-shapefile
	gem install bson
	gem install mongo
	gem install bson_ext


### Epic-Geo
Most of the functions developed for the original project have been moved to a separate gem called epic-geo, a generic FileI/O and visualization tool I'm currently writing for all project EPIC GeoHCI related projects.

The best way to stay up to do date with epic-geo is by using the bundler and pulling source from Github with the following line in your _Gemfile_

	gem 'epic-geo', github: 'jenningsanderson/epic-geo'

_Note: Many of the dependencies for epic-geo are listed above, but not necessarily all, I am trying to keep this updated_

####Mongo Connection
The data for this project is held on Project EPIC's local analytics server on the CU campus.  There are multiple collections created under the ````sandygeo```` database

- ````edited_tweets````: The main collection of tweets cut to the study timeframe: October 20 to November 7, 2012.  Each document is a full tweet, as retrieved from the Twitter API.

- ````coastal_users````: The final collection of 17,627 users that were identified as having a tweet within the highly affected eastern seaboard area as defined by FEMA.

- ````after_sandy````: Tweets between October 1, 2012 and October 22, 2012 that were excluded from the project analysis.

- ````before_sandy````: Tweets between November 7, 2012 and December 1, 2012 that were excluded from the project analysis.

- ````tweets````: The original 260,859 geo-coded tweets extracted from the 22 million tweet keyword collection.  Used to identify geo-coding Twitterers for contextual stream fetching.

- ````userpaths````: Distinct paths for 32,842 users.  Each document contains an array of tweets where each tweet has date, text, entities, and place information.  A GeoJSON Linestring Object exists for each user that tracks the user's path.

- ````user_indiv_tweets````: Similar to userpaths, but not a Linestring, instead each individual tweet with place, text, and timestamp as properties.

- ````most_impacted_users````:



##Project Conventions
- Users are referenced by their id (A long number).  If a user has multiple screen names as their tweets are aggregated, their ````handle```` that is written will be a string of unique usernames separated by commas.


##Project Directories

###fileio/
#####kml_output.rb
Writes

#####identified_users.kml

#####tweet_io.rb
Includes the two classes for interacting with Mongo.  ````SandyMongoClient```` creates an object for querying the database and returning tweets based on various parameters and ````Tweet_JSON_Reader```` reads and imports to mongo, a text file containing valid JSON tweets, separated by newlines.  The main runtime for this script runs an import; however, other scripts use the ````SandyMongoClient```` class for interacting with the database.

#####write_geojson.rb
Uses the ````json```` library to write valid geojson from a variety of inputs.  The main runtime of this script will write both a tweet  and a userpath geojson file from a users collection.

#####write_user_tweets_geojson.rb
Requires the ````write_geojson.rb```` script to generate a folder containing valid geojson objects for each user's tweets.

#####tweet_shape.rb
Uses the ````georuby```` library to create shapefiles from Tweets.  This functionality is deprecated because creating shapefiles for viewing the data is less convenient than KML or GeoJSON files.
