## [Unreleased]

## [0.3.0] - 2026-08-30

- Add `internal_links` to stats: posts ranked by inbound links from other posts
- Source posts can be excluded by tag via `jekyll-stats.link_source_exclude_tags` in `_config.yml`
- `--json` no longer prints "Loading site..." to stdout, so output pipes cleanly to `jq`

## [0.2.0] - 2026-01-03

- Add `--tags` / `-t` option to filter stats by tags

## [0.1.0] - 2025-12-21

- Initial release
