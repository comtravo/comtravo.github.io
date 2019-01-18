# Comtravo Tech Blog

# Local Setup

## Prerequisites
* `make`
* `docker`
* `git`

## Steps
* Clone this repo
* Navigate to the root of this repo
* Run `make develop`
* The local copy of the blog should be available at [`http://127.0.0.1:4000`](http://127.0.0.1:4000)
* Any file changes will be watched and the tech blog re-rendered automagically!
* To bring down the local setup. Run `make stop`


# Creating a New Post

The posts are located in the `_posts` directory and use `markdown`. To create a new one, just create a new markdown file called `YYYY-MM-DD_Post_Title.md`, where `YYYY-MM-DD` can be the current date. Each post has a _front matter_ and some content. The _fron matter_ contains meta data about the post, most of which should be pretty self eplanatory.

```
---
layout: article
title: A Practical Parser for Time Expressions
date: 2018-07-28 11:25:00  # if the publication date is in the future the article will be published on that future date
categories: [time-parsing, ctparse, NLP, pydata]
comments: false
share: true
image:
  teaser: 2018_07_07/teaser.jpg
  feature: 2018_07_07/feature.jpg
description: ctparse is a pure python library (MIT-License) for parsing complex time expressions efficiently.
usemathjax: false  # if you need math symbols turn this one
author: sebastian_mika
---
```

### Images

For the images of the post, create a new directory under `images` and name it with the date prefix of the post markdown file. You can put all the images of the article in that directory, the `feature` and `teaser` images should ideally be called `feature.jpg` and `teaser.jpg`. Please do not use copyrighted images with first acquiring a license - pexels.com has a large collection of free to use images.

## Markdown

All the posts are using markdown. If you're not familiar with markdown GitHub has a useful guide https://guides.github.com/features/mastering-markdown/


## MathJax

All math notation needs to be enclosed in _two_ dollar signs for mathjax to render them.


## Author Details

- add your details to _data/authors.yml
- image 80x80 pixels


# CSS Styleguide

The blog currently uses a Jekyll theme called skinny bones. You can refer to below article for a CSS style guide.


https://mmistakes.github.io/skinny-bones-jekyll/articles/sample-post/


# Writing Guidelines

Useful reading (you can read this in one weekend)
- https://www.abebooks.com/9780134080413/Style-Lessons-Clarity-Grace-12th-0134080416/plp


## General tips

- Know your audience
	- The blog is aimed at Tech-savvy people
- Ask yourself: What has the reader gained after reading the blog post?
- Give yourself enough time. Writing coherent, easy-to-understand text requires time. After about 1-2 hours your thoughts are likely to start drifting and you "lose the plot". Stop, take a break, and come back to the text later.
- Start with a structure: create a rough structure with just headers and then start filling in the details.
- Don't lock yourself down to the structure you created earlier, if you need to change the structure do so.

### Use simple language

 1. Your (ideal) audience is tech-savvy but you basically write for multiple audiences. Keep it simple and clear to make it accessible while still maintaining accuracy.
 2. Cut jargon, don’t make the language unnecessarily complicated.
	- Every team has their own lingo for referring to certain concepts, avoid using specialised terms that are only meaningful internally
	- Ask yourself: Does this language make sense to someone who doesn’t work here
	- For example:
		- "_audience acquisition and retention_" vs. "_building and sustaining a loyal audience_"
		- `leg` and `slice` are meaningful only for the backend team
		- if you can't avoid using specialised terminology, then explain what the term(s) mean.

### Prefer active voice over passive voice
 - Active: They did something
 - Passive: Something was done by them.

_Exception_:
If you want to specifically emphasize the action over the subject, then passive might be fine.
Example: Your account was shut down by our security team.

### Avoid long and complicated sentences
If the sentence is too long, cut it into two.

### Structure
Use sections, or even think about a series of posts for big topics. Format for easy reading (sub-headlines, bullet points, keep paragraphs short).

Introduction _get the reader’s attention_
 1. What is the issue this post talks about (1-2 sentences) and how does that issue relate to Comtravo (1-2 sentences).
 2. A short summary of how the issue is addressed (1-2 sentences)
 3. Tell the reader what they will get out of reading this post

- Give some context (as needed)
- Background/definitions (if necessary)
- Is it something we’ve been working on
- Is it a topic that keeps coming up

Main body:
That’s where you discuss your topic
Remember to use sections (see above)

Conclusion:
Sum up your post/findings
You can also give an outlook or use call to actions


