--[[ =================================================================
    Description:
        All strings (English) used by EventTracker.
    ================================================================= --]]

-- Frame Strings
    ET_ALLNONE_BUTTON_ALL = "All";
    ET_ALLNONE_BUTTON_NONE = "None";
    ET_RESET_BUTTON = "Reset";
    ET_PURGE_BUTTON = "Purge";
    ET_CLOSE_BUTTON = "Close";
    ET_STATE_ON = "On";
    ET_STATE_OFF = "Off";
    ET_TRACKING = "Tracking is "..C_YELLOW.."%s"..C_CLOSE;
    ET_STATE_ONOFF = ET_STATE_ON.." / "..ET_STATE_OFF;
    ET_EVENT_COUNT = "Events/Functions:  "..C_BLUE.."%d"..C_CLOSE;
    ET_EVENTS_TRACKED = "Events/Functions tracked:  "..C_BLUE.."%d"..C_CLOSE;
    ET_MEMORY = "Memory:  "..C_BLUE.."%.2f KB"..C_CLOSE;
    ET_ARGUMENTS_TEXT = "Arguments";
    ET_REGISTERED_TEXT = "Registered by";
    ET_CALLSTACK_TEXT = "Call Stack";
    ET_UNNAMED_FRAME = "< "..C_RED.."Unnamed frame"..C_CLOSE.." >";

    ET_SHOW_DETAILS = "Show details >>";
    ET_HIDE_DETAILS = "Hide details <<";
    ET_TIME_CURRENT = "Time (current) : "..C_BLUE.."%.2f ms"..C_CLOSE;
    ET_TIME_TOTAL = "Time (total) : "..C_BLUE.."%.2f ms"..C_CLOSE;

-- Binding strings
    BINDING_HEADER_ET = "EventTracker Bindings";
    BINDING_NAME_TOGGLEET = "Toggle EventTracker";

    -- Help information
    ET_HELP = { "EventTracker commands:",
                "    /et : open/close EventTracker dialog",
                "    /et { help | ? }: Show this list of commands",
                "    /et add <event>: Add event to be tracked",
                "    /et { remove | del } <event>: Remove event to be tracked",
                "    /et list: List the added tracked events",
                "    /et clear: Remove all added tracked events",
                "    /et off: Turn off tracking",
                "    /et on: Turn on tracking",
                "    /et toggle: Toggle tracking on or off",
                "    /et filter: Filter for events (plain substring). Requires registerall to be active",
                "    /et { removefilter | delfilter }: Remove filter",
                "    /et purge: Purge all event data",
                "    /et reset: Unregister all events, then register only tracked events",
                "    /et { registerall | all }: Register all events to be tracked (# of events not known)",
                "    /et { unregisterall | none }: Unregister all events to be tracked (except for VARIABLES_LOADED)",
                "    /et resetpos: Reset position of the main EventTracker frame",
              };