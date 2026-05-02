# SNAG

A macOS app for downloading multiple GitHub repositories from a user profile at once.

I got tired of cloning repos one by one whenever I wanted to grab someone's projects, so I built this. You paste a GitHub username, it fetches their public repos, and you pick which ones to download. That's it.

## Features

- Fetches all public repos for any GitHub user
- Choose specific repos or download everything at once
- Three download methods: ZIP, HTTPS clone, or SSH clone
- Skip forks, organize repos into folders by language, or overwrite existing ones
- Pause, resume, and cancel downloads mid-batch
- Configurable concurrency (how many repos download in parallel)
- Keeps a history of recently fetched profiles
- Pick any folder as the download destination

## How It Works

The app hits the GitHub REST API to list a user's public repositories (paginated, 100 per page). When you start a download, it spawns concurrent tasks up to the limit you set in settings. ZIP downloads use `ditto` for extraction, and git clones go through `xcrun git`.

There's no authentication, so you're limited to GitHub's unauthenticated rate limit (60 requests/hour). For most use cases that's more than enough.

## Stack

- SwiftUI + AppKit (macOS-only)
- Structured concurrency (`actor`, `TaskGroup`)
- `WKWebView` for GitHub profile previews
- `UserDefaults` for settings and recent profiles
- `Process` for `ditto` (ZIP extraction) and `git clone`
