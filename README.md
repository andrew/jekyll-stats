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

<p>{{ site.data.stats.total_posts }} posts, {{ site.data.stats.total_words }} words, ~{{ site.data.stats.reading_minutes }} minutes reading time.</p>

<p>Average {{ site.data.stats.average_words }} words per post. Longest: <a href="{{ site.data.stats.longest_post.url }}">{{ site.data.stats.longest_post.title }}</a> ({{ site.data.stats.longest_post.words }} words).</p>

<p>First post: {{ site.data.stats.first_post.date }} | Last post: {{ site.data.stats.last_post.date }} | {{ site.data.stats.years_active }} years active.</p>

<h2>Posts by Year</h2>
<table>
  <thead>
    <tr>
      <th style="text-align: left">Year</th>
      <th style="text-align: right">Posts</th>
    </tr>
  </thead>
  <tbody>
{% for year in site.data.stats.posts_by_year %}
    <tr>
      <td>{{ year.year }}</td>
      <td style="text-align: right">{{ year.count }}</td>
    </tr>
{% endfor %}
  </tbody>
</table>

<h2>Top Tags</h2>
<table>
  <thead>
    <tr>
      <th style="text-align: left">Tag</th>
      <th style="text-align: right">Posts</th>
    </tr>
  </thead>
  <tbody>
{% for tag in site.data.stats.tags limit:10 %}
    <tr>
      <td>{{ tag.name }}</td>
      <td style="text-align: right">{{ tag.count }}</td>
    </tr>
{% endfor %}
  </tbody>
</table>

<p><small>Generated {{ site.data.stats.generated_at | date: "%b %d, %Y" }}</small></p>
```

## Development

```bash
bin/setup
rake test
```

## License

MIT License. See [LICENSE](LICENSE) for details.
