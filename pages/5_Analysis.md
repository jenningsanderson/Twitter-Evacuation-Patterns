---
layout: page
title: Analysis
permalink: /analysis/
---

The following link goes to the R markdown html output for visual timeline analysis.  It should open in a new window.

<a href="../analysis/r_timeline/user_timeline_comparisons.html" target="_blank">Visual Timeline Analysis</a>

<ul class="posts">
  {% for post in site.posts %}
    <li>
      <span class="post-date">{{ post.date | date: "%b %-d, %Y" }}</span>
      <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
