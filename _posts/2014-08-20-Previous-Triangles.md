---
layout: post
title: "Triangles (Previous Analysis Method)"
date:   2014-08-20 19:00:00
permalink: /Triangles
---

#Before, During, After

Given the three points of interest for a user,  a triangle is drawn.  Comparing these triangles is done by the following:

![Triangles]({{site.baseurl}}/img_exports/triangle_explanation.png "Triangle Ratios")

Various metrics may then be computed:

````isoceles_ratio```` = The ratio of before-during to during-after edges.

Users can then be filtered by the following triangle paramaters:

1. Perimeter
2. Length of Before-After Edge (if they returned to the same place from where they left or not)

Putting these variables together, we can search for users who's shelter locations make triangles of under a _threshold_ perimeter with a before-after edge under a _threshold_ and an isoceles ratio within a _threshold_

How to determine these thresholds?  See the [latest posts]({{site.baseurl}}/latest)
