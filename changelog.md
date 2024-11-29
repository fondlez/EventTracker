# Changelog for "EventTracker"

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0-fondlez] - 2024-11-28

Initial public release.

### Added
- ported to also support 2.4.3 (The Burning Crusade) client
- right click event in main window to add/remove as a tracked event
- command `/et clear`: Remove all added tracked events
- command `/et reset`: Unregister all events, then register only tracked 
  events
- "All/None" toggle button which is equivalent to `/et registerall` 
  ("All") or `/et unregisterall' ("None")
- "Reset" button which click is equivalent to `/et reset`. Shift-clicking is the 
  same as `/et clear` then `/et reset`
- some missing mouse wheel scrolling features
- README.md
- changelog.md

## [1.0.0-fondlez] - 2024-11-19

### Added
- command `/et add`: Add event to be tracked
- command `/et { remove | del }`: Remove event to be tracked
- command `/et list`: List the added tracked events
- command `/et off`: Turn off tracking
- command `/et on`: Turn on tracking
- command `/et toggle`: Toggle tracking on or off
- command `/et filter`: Filter for events (plain substring)
- command `/et { removefilter | delfilter }`: Remove filter
- command `/et purge`: Purge all event data
- shift-click event in main window to remove event and purge its data
- editable Lua suport for Ignored events in EventTracker_events.lua

### Changed
- prevent Escape from closing main window dialog like a special menu