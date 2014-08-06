---
title: Data Set
layout: page
permalink: /data/
---

#The DataSet

There were over 20 million tweets generated during Hurricane Sandy which referenced Sandy.  These tweets came from (x) distinct users.

(155,507 users)?

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
