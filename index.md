---
layout: archive
permalink: /
title: "Latest Posts"
excerpt:
image:
  feature: features/coffee_feature.jpg
---

<div class="tiles">
{% for post in site.posts %}
	{% include post-grid.html %}
{% endfor %}
</div><!-- /.tiles -->
