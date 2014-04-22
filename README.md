## Hurricane Sandy Geo-Coded Tweets Project
#### Project Lead: Jennings Anderson
##### Members: Andrew Hardin, Ellie Falletta

[Project EPIC](http://epic.cs.colorado.edu), Geography 5303

_This project will look at all of the Geo-Coded tweets from Hurricane Sandy_


##About
Somewhere on order of 1% of tweets are geo-tagged.  That is, the metadata of the tweet includes the lat/long of the location from which the tweet was sent.


##Movation
What can be learned from using a person's Twitter activity over the course of Superstorm Sandy as a proxy for their location?

##Datasets
1. ~300,000 geo-coded tweets
2. Storm data from USGS?
3. Build-Environment Information from OpenStreetMap


##Timeline
This project aims to be finished by the end of April, 2014

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

most_impacted_users
nynj_users
sandbox
system.indexes
user_indiv_tweets
userpaths


##Project Directories

###fileio Directory/
####kml_output.rb
Writes 


###mongo Directory/
####linestring_reduce.js
Map reduce function to generate the ````usertracks```` collection from the ````edited_tweets```` collection



###extract_scripts/


###parsers/

###userAnalysis/
The Visual Studio project that take the extracted users and outputs diagnostic files, such as a KML, a CSV of perimeters, and each user's median points.
