---
layout: default
permalink: /about/
title: Who We Are
image:
  feature: features/ct-office-feature.jpg
share: false
comments: false
published: true
---

<div id="main" role="main">
	<article class="wrap" itemscope itemtype="http://schema.org/Article">
		{% if page.image.feature %}
		<div class="page-feature">
			<div class="page-image">
				<img src="{{ site.url }}/images/{{ page.image.feature }}" class="page-feature-image" alt="{{ page.title }}" itemprop="image">
				{% if page.image.credit %}{% include image-credit.html %}{% endif %}
			</div><!-- /.page-image -->
		</div><!-- /.page-feature -->
		{% endif %}
        <div class="page-title">
			<h1>{{ page.title }}</h1>
		</div>
		<div class="inner-wrap">
			<div id="content" class="page-content" itemprop="articleBody">
                <footer class="page-footer">
                <h4>The Comtravo tech blog is written by many great minds. Not surprinsgly many of them are current or former Comtravo employees.</h4>
                {% for author in site.data.authors %}
                    <div class="author-image">
                        <img src="{{ site.url }}/images/{{ author[1].avatar }}" alt="{{ author[1].name }}">
                    </div><!-- ./author-image -->
                    <div class="author-content">
                        <h3 class="author-name" > {% if author[1].web %}<a href="{{ author[1].web }}" itemprop="author">{{ author[1].name }}</a>{% else %}<span itemprop="author">{{ author[1].name }}</span>{% endif %}</h3>
                        {% if author[1].role %}<p>{{ author[1].role }}</p>{% endif %}
                        {% if author[1].bio %}<p class="author-bio">{{ author[1].bio }}</p> {% else %} <br/> {% endif %}
                    </div><!-- ./author-content -->
                {% endfor %}
                </footer>

				<hr />
			</div><!-- /.content -->
		</div><!-- /.inner-wrap -->
	</article><!-- ./wrap -->
</div><!-- /#main -->

