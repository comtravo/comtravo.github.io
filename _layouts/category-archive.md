---
layout: default
---

<div id="main" role="main">			
	<div class="wrap">
		{% if page.image.feature %}
		<div class="page-feature">
			<div class="page-image">
				<img src="{{ site.url }}/images/{{ page.image.feature }}" class="page-feature-image" alt="{{ page.title }}">
				{% if page.image.credit %}{% include image-credit.html %}{% endif %}
			</div><!-- /.page-image -->
		</div><!-- /.page-feature -->
		{% endif %}

		<div class="page-title">
            <h1>Posts with {{ page.type }} '{{ page.title }}'</h1>
		</div>
		<div class="archive-wrap">
			<div class="page-content">

              {% for post in page.posts %}
	            {% include post-grid.html %}
              {% endfor %}

			</div><!-- /.page-content -->
		</div class="archive-wrap"><!-- /.archive-wrap -->
	</div><!-- /.wrap -->
</div><!-- /#main -->
