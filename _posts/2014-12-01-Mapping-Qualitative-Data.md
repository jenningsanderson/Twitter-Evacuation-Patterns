---
layout: map
title:  "Mapping Qualitative Data"
date:   2014-12-01 11:00:00
permalink: /mapanalysis
---

#Mapping Our Qualitative Data

{% for user in site.data.qualmaps %}
<a href="{{site.baseurl}}/mapanalysis?user={{ user[0] }}">{{user[0]}}</a>
{% endfor %}

<!-- <nav id='filters' class='filter-ui'></nav> -->
<script src="{{site.baseurl}}/assets/js/qualitative_map.js">