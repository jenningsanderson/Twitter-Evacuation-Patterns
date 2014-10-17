---
title: Data Set
layout: page
permalink: /data/
---

There were 22,250,274 tweets generated during Hurricane Sandy which referenced Sandy.  260,589 of these tweets (1.1%) were geotagged from 154,703 users.

Collecting these user's **geotagged** _contextual stream_ of tweets yields a total of 22 million tweets.

The tweets were next limited to the time frame of October 1, 2012 - December 31, 2012.

Next, users with less than 3 tweets between **October 28** and **November 3** were removed.  Later analysis will most likely ignore these users (and users with many more tweets) anyway because they will become _unclassifiable_ for not having distinct geo-clusters of personal Twitter activity.

Similarly, users were limited to 1,200 tweets (Only a few users exceeded this count) because it caused a stack-overflow on the database server when that many data points were used in calculations.  In these cases, we kept the middle 1,200 tweets from a user that validated the above constraints.

The working dataset includes **20,317 users**.  See the [Tweet Statistics page]({{site.baseurl}}/Tweet_Statistics) for more information on this distribution.


##Geo-Based Filtering
The following bounding box is used to pick out Twitterers that had the potential to be most physically affected by the storm.  This bounding box is referred to internally as the _NCAR Bounding Box_, because it was first identified by project collaborators at NCAR.

<script alt="NCAR Bounding Box" src="https://gist.github.com/582f9f1033eb5f490609.js"></script>

14,338 Twitterers in the collection are ignored because their base cluster does not fall within this bounding box. This makes it clear that Sandy was discussed at a very local global scale: 

<script src="https://gist.github.com/jenningsanderson/6d4802a39dda445300a5.js"></script>

Within the bounding box for the most directly affected users, we filter even further by identifying those on coastlines and in evacuation zones:

<script src="https://gist.github.com/b6f044286f9bb1bc292f.js"></script>

For further reference, here is a static image of the New York City Evacuation Zones: 
(White = A, Light Purple = B, Dark Purple = C)

![NYC Evacuation Zones]({{site.baseurl}}/img_exports/NYC_evacuation_zones.png)