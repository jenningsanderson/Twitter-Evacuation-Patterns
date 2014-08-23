---
layout: post
title:  "New Data Structure""
date:   2014-08-23 1:45:00
---




###Twitterer
The Twitterer model has changed dramatically, but the following metrics are now available:


| Variable					| Type		|
|------------------------------------|
| ```shelter_in_place```	| Boolean |



```before_hazard_level```



```confidence```
A ranking variable that is given weight to the confidence of the metric as it runs.

| Value			| Description |
|----------------------------------------
|10| User moved during the storm, starting from their _home_.
|20| User moved during the storm starting from their _home_ and returned to their _home_.
|30| User satisfies both above requirements and clearly only went to one other location.