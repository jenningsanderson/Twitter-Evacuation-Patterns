---
layout: post
title:  "New Data Structure""
date:   2014-08-23 1:45:00
---




##Twitterer
The Twitterer model has changed dramatically, but the following metrics are now available:


###Basic Filtering Values
| Variable					| Type		| Description |
|--------------------------------------------------|
| ```unclassifiable```	| Boolean | At some point, the method has deemed this user as unclassifiable due to a lack of information _Update: Users with no affected path are also considered unclassifiable currently_ |
| ```path_affected```	| Boolean | Whether or not this user's path intersects with the bounding box |
| ```shelter_in_place```	| Boolean | If the method has determined at any point the user sheltered in place, then this value is set to true |





```before_hazard_level```



```confidence```
A ranking variable that is given weight to the confidence of the metric as it runs.

| Value			| Description |
|----------------------------------------
|10| User moved during the storm, starting from their _home_.
|20| User moved during the storm starting from their _home_ and returned to their _home_.
|30| User satisfies both above requirements and clearly only went to one other location.



