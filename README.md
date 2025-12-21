# jekyll-stats

A Jekyll plugin that adds a `jekyll stats` command to display site statistics.

## Installation

Add to your Jekyll site's Gemfile:

```ruby
gem "jekyll-stats"
```

Then run `bundle install`.

## Usage

Run from your Jekyll site directory:

```bash
# Print stats to terminal
jekyll stats

# Save stats to _data/stats.json
jekyll stats --save

# Output raw JSON to stdout
jekyll stats --json

# Include drafts in calculations
jekyll stats --drafts
```

### Terminal Output

```
Site Statistics
-----------------------------------
Posts: 127 (43,521 words, ~3h 38m read time)
Avg: 343 words | Longest: "My Best Post" (2,847 words)
First: 2019-03-14 | Last: 2025-12-18 (6.8 years)
Frequency: 1.6 posts/month

Posts by Year:
  2025: ████████████ 24
  2024: ███████████████████ 38
  2023: ██████████████ 28

Top 10 Tags:
  ruby (34) | opensource (28) | packages (19)

Categories:
  code (45) | cars (32)
-----------------------------------
```

### JSON Output

The `--save` flag writes `_data/stats.json` with this structure:

```json
{
  "generated_at": "2025-12-21T09:30:00Z",
  "total_posts": 127,
  "total_words": 43521,
  "reading_minutes": 218,
  "average_words": 343,
  "longest_post": { "title": "My Best Post", "url": "/2024/01/my-best-post", "words": 2847 },
  "shortest_post": { "title": "Quick Note", "url": "/2024/03/quick-note", "words": 89 },
  "first_post": { "title": "Hello World", "url": "/2019/03/hello-world", "date": "2019-03-14" },
  "last_post": { "title": "Recent Post", "url": "/2025/12/recent-post", "date": "2025-12-18" },
  "years_active": 6.8,
  "posts_per_month": 1.6,
  "posts_by_year": [{ "year": 2025, "count": 24 }, { "year": 2024, "count": 38 }],
  "posts_by_month": [{ "month": "2025-12", "count": 3 }],
  "posts_by_day_of_week": { "monday": 23, "tuesday": 18, "wednesday": 15, "thursday": 20, "friday": 22, "saturday": 14, "sunday": 15 },
  "tags": [{ "name": "ruby", "count": 34 }, { "name": "opensource", "count": 28 }],
  "categories": [{ "name": "code", "count": 45 }, { "name": "cars", "count": 32 }],
  "drafts_count": 3
}
```

## Building a Stats Page

After running `jekyll stats --save`, create a stats page using Liquid:

```liquid
---
layout: page
title: Site Statistics
---

<p>
  <strong>{{ site.data.stats.total_posts }}</strong> posts,
  <strong>{{ site.data.stats.total_words | divided_by: 1000 }}k</strong> words,
  <strong>{{ site.data.stats.reading_minutes | divided_by: 60 }}</strong> hours of reading.
</p>

<p>
  Writing since {{ site.data.stats.first_post.date }} ({{ site.data.stats.years_active }} years).
  Averaging {{ site.data.stats.posts_per_month }} posts per month.
</p>

<h2>Posts by Year</h2>
<ul>
{% for year in site.data.stats.posts_by_year %}
  <li>{{ year.year }}: {{ year.count }} posts</li>
{% endfor %}
</ul>

<h2>Top Tags</h2>
<ul>
{% for tag in site.data.stats.tags limit:10 %}
  <li>{{ tag.name }} ({{ tag.count }})</li>
{% endfor %}
</ul>

<h2>Extremes</h2>
<ul>
  <li>Longest: <a href="{{ site.data.stats.longest_post.url }}">{{ site.data.stats.longest_post.title }}</a> ({{ site.data.stats.longest_post.words }} words)</li>
  <li>Shortest: <a href="{{ site.data.stats.shortest_post.url }}">{{ site.data.stats.shortest_post.title }}</a> ({{ site.data.stats.shortest_post.words }} words)</li>
</ul>

<h2>Day of Week</h2>
<p>
  I write most on
  {% assign max_day = "" %}
  {% assign max_count = 0 %}
  {% for day in site.data.stats.posts_by_day_of_week %}
    {% if day[1] > max_count %}
      {% assign max_day = day[0] %}
      {% assign max_count = day[1] %}
    {% endif %}
  {% endfor %}
  {{ max_day | capitalize }}s ({{ max_count }} posts).
</p>
```

## Development

```bash
bin/setup
rake test
```

## License

MIT License. See [LICENSE](LICENSE) for details.
