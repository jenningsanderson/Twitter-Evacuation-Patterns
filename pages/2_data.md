---
title: Data Set
layout: page
permalink: /data/
---

There were 22,250,274 tweets generated during Hurricane Sandy which referenced Sandy.  260,589 of these tweets (1.1%) were geotagged from 154,703 users.

Collecting these user's **geotagged** _contextual stream_ of tweets yields a total of 22 million tweets.

The tweets were next limited to the time frame of October 1, 2012 - December 31, 2012.

Next, users with less than 3 tweets between **October 28** and **November 3** were removed.  Later analysis will most likely ignore these users (and users with many more tweets) anyway because they will become _unclassifiable_ for not having distinct clusters.

Similarly, users were limited to 1,200 tweets (Only a few users exceeded this count) because it caused a stack-overflow on the database server when that many data points were used in calculations.  In these cases, we kept the middle 1,200 tweets from a user that validated the above constraints. 

The working dataset includes **29,137 users** with **3,135,852 tweets**.  See the [Statistics page]({{site.baseurl}}/Statistics) for histograms of this breakdown.


##Geo-Based Filtering
The following bounding box is used to pick out Twitterers that were most affected.  This box is mostly to remote Twitteresr form local Twitterers, as the dataset includes many tweets from overseas that mention the event.
<script alt="NCAR Bounding Box" src="https://gist.github.com/582f9f1033eb5f490609.js"></script>

16,791 Twitterers in the collection are ignored because their _user_path_ does not intersect with this bounding box.  The remaining users are classified as follows:

####Intersecting Users (12,338):
A user's path (the LineString constructed from each of their tweet points) intersects (or lies within) with this bounding box.

####Potentially affected affected Users (8,095):
A user's calculated _before_ shelter location lies within this bounding box.  Of these users, however, only 5,936 contain enough information to be classified by the model.

####Affected Coastline (1,798):
To get the best idea of which Twitterers faced a protective decision regarding their location, we buffered the coastline within the bounding box above by 1500 meters (1.5km).  This unit was chosen because it best captures the barrier islands of New Jersey as well as the New York City mandatory Evacuation Zones (Zone A), specifically for Manhattan and Rockaway Beach, areas that were hit very hard by the storm.
<script src="https://gist.github.com/jenningsanderson/31b08d9c3d3d8a998e63.js"></script>

For reference, the New York City Evacuation Zones are pictured below: (White = A, Light Purple = B, Dark Purple = C)

![NYC Evacuation Zones]({{site.baseurl}}/img_exports/NYC_evacuation_zones.png)


#Database Design

1. Running on mongoDB, utilizing MongoMapper to allow object interactions.

Each user is stored as a document with embedded tweet documents:

The basic attributes of the structure are:

	Twitterer
      -ID
      -Handle
      -Tweet Count
      Tweets
        -Coordinates
        -Text
        -Time