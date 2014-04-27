## Hurricane Sandy Geo-Coded Tweets Project
#### Project Lead: Jennings Anderson
##### Members: Andrew Hardin, Ellie Falletta

[Project EPIC](http://epic.cs.colorado.edu), Geography 5303

_This project looks at all of the Geo-Coded tweets from Hurricane Sandy_


##About
Somewhere on order of 1% of tweets are geo-tagged.  What can be learned about a Twitterer's movement behavior during Hurricane Sandy?

##Dependencies

Ruby Requirements
````
gem install georuby
gem install rgeo-shapefile
gem install bson
gem install mongo
gem install bson_ext
````

####Mongo Connection
The data for this project is held on Project EPIC's local analytics server on the CU campus.  There are multiple collections created under the ````sandygeo```` database

- ````edited_tweets````: The main collection of tweets cut to the study timeframe: October 20 to November 7, 2012.  Each document is a full tweet, as retrieved from the Twitter API.

- ````coastal_users````: The final collection of 17,627 users that were identified as having a tweet within the highly affected eastern seaboard area as defined by FEMA.

- ````after_sandy````: Tweets between October 1, 2012 and October 22, 2012 that were excluded from the project analysis.

- ````before_sandy````: Tweets between November 7, 2012 and December 1, 2012 that were excluded from the project analysis.

- ````tweets````: The original 260,859 geo-coded tweets extracted from the 22 million tweet keyword collection.  Used to identify geo-coding Twitterers for contextual stream fetching.

- ````userpaths````: Distinct paths for 32,842 users.  Each document contains an array of tweets where each tweet has date, text, entities, and place information.  A GeoJSON Linestring Object exists for each user that tracks the user's path.

-````user_indiv_tweets````: Similar to userpaths, but not a linestring

-````most_impacted_users````: 



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

###mongo/
#####linestring_reduce.js
Map reduce function to generate the ````usertracks```` collection from the ````edited_tweets```` collection.


###extract_scripts/
#####

###parsers/

###analysis/
#####Twitter_In_Evac.py
A python script

###userAnalysis/
The Visual Studio project that take the extracted users and outputs diagnostic files, such as a KML, a CSV of perimeters, and each user's median points.
