# EventTracker

Event Tracker is an addon for World of Warcraft that allows you to view detailed 
information on tracked events.

Tested clients: 3.3.5 (Wrath of the Lich King).

## Slash Commands

**/et** - open/close EventTracker dialog

**/et { help | ? }** - Show this list of commands

**/et add <event>** - Add event to be tracked

**/et { remove | del } <event>** - Remove event to be tracked

**/et list** - List the added tracked events

**/et off** - Turn off tracking

**/et on** - Turn on tracking

**/et toggle** - Toggle tracking on or off

**/et filter** - Filter for events (plain substring). Requires `registerall` to 
be active

**/et { removefilter | delfilter }** - Remove filter

**/et purge** - Purge all event data

**/et registerall** - Register all events to be tracked (# of events not known)

**/et unregisterall** - Unregister all events to be tracked (except for 
VARIABLES_LOADED)

**/et resetpos** - Reset position of the main EventTracker frame

## Feature Notes

### Shift Click Events in the Main Window

- shift-clicking any event in the list of events of the main window will 
unregister the event and purge all data for that event.

### Add Events from Slash Commands

- events added with `/et add`, removed with `/et remove` and shown with 
`/et list` are saved across login sessions. Using `/et unregisterall` at any 
time will remove all these events.

### Filter All Registered Events

- any string added with `/et filter` will be used to do a plain substring search 
of event names after `registerall` is active. These events will be tracked. If 
no string is given, the current filter is displayed.

### EventTracker_events.lua 

The addon file `EventTracker_events.lua` can be edited to directly add two lists
of events. This is useful for bulk or permanent changes.

- `ET_TRACKED_EVENTS`: add to this array of events to track additional events
- `ET_IGNORED_EVENTS`: add to this array of events to permanently ignore events 
after `registerall` is enabled. 

These event lists are unaffected by the `/et filter` slash command.

## Credits

The original author of EventTracker is redeye <wowaddon@xs4all.nl>, with an
initial public release in June 8, 2009.

To raise any issues with this release, please use the Issues section of the
repository at http://github.com/fondlez/EventTracker
