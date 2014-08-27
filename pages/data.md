---
title: Data Set
layout: page
permalink: /data/
---

There were 22,250,274 tweets generated during Hurricane Sandy which referenced Sandy.  260,589 of these tweets (1.1%) were geotagged from 154,703 users.

Collecting these user's **geotagged** _contextual stream_ of tweets yields a total of 22 million tweets.

The tweets were next limited to the time frame of October 1, 2012 - December 31, 2012.

Next, users with less than 3 tweets between **October 28** and **November 3** were removed.  Later analysis will most likely ignore these users (and users with many more tweets) anyway because they will become _unclassifiable_ for not having distinct clusters.

The working dataset includes **29,119 users** with **3,118,108 tweets**.  See the [Statistics page]({{site.baseurl}}/Statistics) for histograms of this breakdown.

 

##Geo-Based Filtering
The first round of geo-based filtering is based on the following crude bounding box:

![Original Geo bounding box]({{site.baseurl}}/img_exports/maps/ncar_bounding_box.png)

16,791 Twitterers in the collection are ignored because their path does not intersect with this bounding box.  The remaining users are classified as follows:

####Intersecting Users (12,328):
A user's path (the LineString constructed from each of their tweet points) intersects (or lies within) with this bounding box. 
![Intersecting User (Potentially Affected User)]({{site.baseurl}}/img_exports/intersecting_users_example.png)

 
####Potentially affected affected Users (8,092):
A user's calculated _before_ shelter location lies within this bounding box.

![Highly Affected User]({{site.baseurl}}/img_exports/highly_impacted_users_example.png)

####Highly Impacted User (884):
A user's calculated _before_ shelter location lies within a known evacuation zone.  NYC Evacuation Zones (A,B,C) pictured below:

|Zone | Number of Users |
|-----------------------|
|A| 133 |
|B| 284 |
|C| 487 |


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