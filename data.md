---
title: Data Set
layout: page
permalink: /data/
---

#The DataSet

There were 22,250,274 tweets generated during Hurricane Sandy which referenced Sandy.  260,589 of these tweets (1.1%) were geotagged from 154,703 users.

Collecting these user's geotagged _contextual stream_ of tweets yields a total of 22 million tweets.

Further time-filtering for October 22 - November 7 and manual filtering of easy to find spam, leaves a dataset of (1.9 million tweets)



##Geo-Based Filtering
The first round of geo-based filtering is based on the following crude box:

![]

**Geotagged count**

Sorting this dataset dramatically, the following filters are applied:
-- Reference the Final Presentation from Geography --
 1. sf
 2. sdf
 3. sd


#Database Design

1. Running on mongoDB, utilizing MongoMapper to allow objects.

Each user is a document with embedded tweet documents

```
Twitterer
  -ID
  -Handle
  -Tweet Count

  Tweets
    -Coordinates
    -Text
    -Time
```
