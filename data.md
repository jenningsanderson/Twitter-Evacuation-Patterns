---
title: Data Set
layout: page
permalink: /data/
---

There were 22,250,274 tweets generated during Hurricane Sandy which referenced Sandy.  260,589 of these tweets (1.1%) were geotagged from 154,703 users.

Collecting these user's geotagged _contextual stream_ of tweets yields a total of 22 million tweets.

Further time-filtering for October 22 - November 7 and manual filtering of easy to find spam,

Next, users with less than 15 tweets total were removed.

The working dataset includes **20,317 users** with **1,653,031 tweets**.



##Geo-Based Filtering
The first round of geo-based filtering is based on the following crude box:

![Original Geo bounding box]({{site.baseurl}}/img_exports/geo_affected_boundary.png)

The following two counts are available:

####Intersecting User ():
A user's path (the linestring constructed from each of their tweet points) intersects with this bounding box.
![Intersecting User (Potentially Affected User)]({{site.baseurl}}/img_exports/intersecting_users_example.png)


####Potentially highly affected User ():
A user's calculated _before_ shelter location lies within this bounding box.
![Highly Affected User]({{site.baseurl}}/img_exports/highly_impacted_users_example.png)

####Highly Impacted User (Number coming):
A user's calculated _before_ shelter location lies within a known evacuation zone.  NYC Evacuation Zones (A,B,C) pictured below:
![NYC Evacuation Zones]({{site.baseurl}}/img_exports/NYC_evacuation_zones.png)


#Database Design

1. Running on mongoDB, utilizing MongoMapper to allow object interactions.

Each user is stored as a document with embedded tweet documents:

The main features of the structure are:

````
Twitterer
    -ID
    -Handle
    -Tweet Count

    Tweets
      -Coordinates
      -Text
      -Time
````
