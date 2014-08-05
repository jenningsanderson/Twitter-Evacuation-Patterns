---
layout: page
title: Design
permalink: /design/
---

#User Shelter

The main design of this work is to identify where a user took shelter at various times during Hurricane Sandy


##Step 1: Establish Time bins

These times within the storm are broken into the following bins:

Before | During | After
:-----:| :-----:| :----:
October 22 - 28 | October 28 - Nov 1 | November 1 - December 7 |


##Step 2: Identify clusters in time & space

![DBScan Example]({{site.baseurl}}/img_exports/DB_Scan_GoogleEarth.png "DB Scan Example")

Using the DBscan algorithm, tweets are clustered by geospatial density.  Each of these clusters is then analyzed for regularity.  The ranking is as follows:

```Density``` = (number of tweets)<sup>2</sup> / (area of convex hull around tweets)

```Time Clusters``` = Value between 1 and 8: Number of blocks of 3 hours in which the tweets in that cluster occur.  (A measure of deviation within the hours of the day when a user tweets)

```Weighted Location``` = The median location of the cluster which maximizes ```Density/Time Clusters```

This weighted location is then set as the 'before', 'during', or 'after' location of a user with reference to where they were during that time.

![Before During After]({{site.baseurl}}/img_exports/BeforeDuringAfter.png "Three POIs")
