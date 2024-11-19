--[[ =================================================================
    Description:
        EventTracker is a simple AddOn that informs, by means of a
        chat message, when specific events are triggered within the
        game.

        The main purpose is to determine which events get triggered
        at what stage, to ultimately get a better understanding about
        the internals of the game, and hopefully help out in identifying
        why certain things happen or things might be failing all together.

        Update the file EventTracker_events.lua to specify which events
        need to be tracked.

    Contact:
        For questions, bug reports visit the website or send an email
        to the following address: wowaddon@xs4all.nl

    Dependencies:
        None

    Credits:
        A big 'Thank You' to all the people at Blizzard Entertainment
        for making World of Warcraft.
    ================================================================= --]]

-- local variables
    local ET_FILTER = nil;

-- Local table functions
    local tinsert, wipe = table.insert, table.wipe;
    local lower, upper, substr = string.lower, string.upper, string.sub;

-- Function to create array of return values
    function pack(...)
        return arg;
    end

-- Send message to the default chat frame
    function EventTracker_Message( msg, prefix )
        -- Initialize
        local prefixText = "";

        -- Add application prefix
        if ( prefix ) then
            prefixText = C_GREEN..ET_NAME..": "..C_CLOSE;
        end;

        -- Send message to chatframe
        DEFAULT_CHAT_FRAME:AddMessage( prefixText..( msg or "" ) );
    end;

-- Handle EventTracker initialization
    function EventTracker_Init()
        -- Initiliaze all parts of the saved variable
        if ( not ET_Data ) then ET_Data = {}; end;
        if ( not ET_Data["active"] ) then ET_Data["active"] = true; end;
        if ( not ET_Data["events"] ) then ET_Data["events"] = {}; end;

        -- Register slash commands
        SlashCmdList["EVENTTRACKER"] = EventTracker_SlashHandler;
        SLASH_EVENTTRACKER1 = "/et";
        SLASH_EVENTTRACKER2 = "/eventtracker";
    end;

-- Register events
    function EventTracker_RegisterEvents( self )
        -- Always track VARIABLES_LOADED
        self:RegisterEvent( "VARIABLES_LOADED" );

        -- Track other events
        for key, value in pairs( ET_TRACKED_EVENTS ) do
            self:RegisterEvent( strtrim( upper( value ) ) );
        end;
        
        -- Track additional events
        local events = ET_Data and ET_Data["events"]
        if events then
          for key, value in pairs( events ) do
              this:RegisterEvent( strtrim( upper( value ) ) );
          end;        
        end
    end;
    
-- Remove the events listed to be ignored
    function EventTracker_RemoveIgnoredEvents()
        -- Track other events
        for _, value in pairs( ET_IGNORED_EVENTS ) do
            EventTracker:UnregisterEvent( strtrim( upper( value ) ) );
        end;
    end;

-- Handle startup of the addon
    function EventTracker_OnLoad( self )

        -- Show startup message
        EventTracker_Message( ET_STARTUP_MESSAGE, false );
        -- Register events to be monitored
        EventTracker_RegisterEvents( self );
    end;

-- Show or hide the Main dialog
    function EventTracker_Toggle_Main()
        if(  EventTrackerFrame:IsVisible() ) then
            EventTrackerFrame:Hide();
        else
            -- Show the frame
            EventTrackerFrame:Show();
            EventTrackerFrame:SetBackdropColor( 0, 0, 0, .5 );

            -- Update the UI
            EventTracker_UpdateUI();
        end;
    end;

-- Show or hide the event detail dialog
    function EventTracker_Toggle_Details()
        if( EventDetailFrame:IsVisible() ) then
            EventDetailFrame:Hide();
            ExpandCollapseButton:SetText( ET_SHOW_DETAILS );
        else
            -- Show the frame
            EventDetailFrame:Show();
            EventDetailFrame:SetBackdropColor( 0, 0, 0, .5 );
            ExpandCollapseButton:SetText( ET_HIDE_DETAILS );
        end;
    end;
    
    local function removeIf(t, predicate)
        local ikeep = 1
        local n = #t
        
        for i = 1, n do
            -- Invert predicate to check if keeping
            if not predicate(t, i, ikeep) then
                -- Skipping past next keep index implies something removed
                if i ~= ikeep then
                    -- If something removed, next keep index must be available
                    t[ikeep] = t[i]
                    -- Clear out invalid array item
                    t[i] = nil
                end
                -- Next past-the-end contiguous keep index for array
                ikeep= ikeep + 1
            else
                t[i] = nil
            end
        end
    end
    
-- Purge data for specific event
    function EventTracker_PurgeEvent( purgeEvent )
        -- Purge highlevel event info
        ET_Events[purgeEvent].count = 0;
        
        local function canPurge(t, i)
          local event = unpack( t[i] )
          return event == purgeEvent
        end
        
        -- Remove events from UI elements array
        removeIf(ET_EventDetail, canPurge)

        -- Update UI elements
        EventCallStack:SetText( "" );
        EventTracker_Scroll_Details();
        EventTracker_Scroll_Arguments();
        EventTracker_Scroll_Frames();
        EventTracker_UpdateUI();
    end;

-- Purge event data
    function EventTracker_Purge()
        -- Clear out old data
        wipe( ET_Events );
        wipe( ET_EventDetail );
        wipe( ET_ArgumentInfo );
        wipe( ET_FrameInfo );
        ET_CurrentEvent = nil;

        -- Update UI elements
        EventCallStack:SetText( "" );
        EventTracker_Scroll_Details();
        EventTracker_Scroll_Arguments();
        EventTracker_Scroll_Frames();
        EventTracker_UpdateUI();
    end;

-- Add data to the tracking stack (for internal usage)
    local function EventTracker_AddInfo( event, data, realevent, time_usage, call_stack )
        -- Track details
        if (not ET_Events[event] ) then
            ET_Events[event] = {};
        end;
        ET_Events[event].count = ( ET_Events[event].count or 0 ) + 1;
        if ( time_usage ) then
            ET_Events[event].time = ( ET_Events[event].time or 0 ) + time_usage;
        end;
        tinsert( ET_EventDetail, { event, time(), data, realevent, time_usage, call_stack } );

        -- Update frame
        if(  EventTrackerFrame:IsVisible() ) then
            EventTracker_Scroll_Details();
            EventTracker_UpdateUI();
        end;
    end;

-- Add data to the tracking stack (for external usage)
    function EventTracker_TrackProc( procname, arginfo )
        -- Store original function
        ET_ProcList[procname] = _G[procname];

        -- Add argument information if provided
        if ( arginfo ) then
            ET_Static[procname] = arginfo;
        end;

        -- Define replacement function (includes timing information)
        _G[procname] = function( ... )
            local start = debugprofilestop();
            local retval = { ET_ProcList[procname]( ... ) };
            local usage = debugprofilestop() - start;
            local call_stack = debugstack( 2 );
            EventTracker_AddInfo( procname, { ... }, false, usage, call_stack );
            if ( retval ) then return unpack( retval ); end;
        end;
    end;

-- Handle events sent to the addon
    function EventTracker_OnEvent( self, event, ... )
        local logEvent = true;

        if ( event == "VARIABLES_LOADED" ) then
            EventTracker_Init();
        end;

        -- Store event data
        if ( ET_Data["active"] ) then
            if ET_FILTER then
                -- Prevent event from being logged when it does not match the filter
                if not event:find( ET_FILTER, 1, true ) then
                    logEvent = false;
                end;

                -- But be sure to include it when it appears within ET_TRACKED_EVENTS
                if tContains( ET_TRACKED_EVENTS, event ) then
                    logEvent = true;
                end;
            end;

            if ( logEvent ) then
                EventTracker_AddInfo( event, { ... }, true );
            end;
        end;
     end;

-- Build strings for argument names and data (incl proper colors and nil handling)
    function EventTracker_GetStrings( event, index, value )
        local argName, argData;

        if ( ET_Static[event] ) then
            argName = ( ET_Static[event][index] or ET_UNKNOWN );
        else
            argName = index;
        end;

        argData = tostring(value or ET_NIL);

        return C_BLUE..argName..C_CLOSE, C_YELLOW..argData..C_CLOSE;
    end;

-- Scroll function for event details
    function EventTracker_Scroll_Details()
        local length = #ET_EventDetail;
        local line, index, button, argInfo, argName, argData;
        local offset = FauxScrollFrame_GetOffset( EventTracker_Details );
        local argName, argData;

        -- Update scrollbars
        FauxScrollFrame_Update( EventTracker_Details, length+1, ET_DETAILS, 30 );

        -- Redraw items
        for line = 1, ET_DETAILS, 1 do
            index = offset + line;
            button = _G["EventItem"..line];
            button:SetID( line );
            button:SetAttribute( "index", index );
            if index <= length then
                local event, timestamp, data, realevent, time_usage, call_stack = unpack( ET_EventDetail[index] );
                _G["EventItem"..line.."InfoEvent"]:SetText( event );
                _G["EventItem"..line.."InfoTimestamp"]:SetText( date( "%Y-%m-%d %H:%M:%S", timestamp ) );
                argInfo = "";

                for key, value in pairs( data ) do
                    argName, argData = EventTracker_GetStrings( event, key, value );
                    argInfo = argInfo..", "..argName.." = "..argData;
                end;
                _G["EventItem"..line.."InfoData"]:SetText( substr( argInfo, 3 ) );
                button:Show();
                button:Enable();
            else
                button:Hide();
            end;
        end;
    end;

-- Scroll function for event arguments
    function EventTracker_Scroll_Arguments()
        local length = #ET_ArgumentInfo;
        local line, index, button, argName, argData;
        local offset = FauxScrollFrame_GetOffset( EventTracker_Arguments );

        -- Update scrollbars
        FauxScrollFrame_Update( EventTracker_Arguments, length+1, ET_ARGUMENTS, 16 );

        -- Redraw items
        for line = 1, ET_ARGUMENTS, 1 do
            index = offset + line;
            button = _G["EventArgument"..line];
            button:SetID( line );
            button:SetAttribute( "index", index );
            if index <= length then
                argName, argData = EventTracker_GetStrings( ET_CurrentEvent, index, ET_ArgumentInfo[index] );
                _G["EventArgument"..line.."InfoArgument"]:SetText( argName );
                _G["EventArgument"..line.."InfoData"]:SetText( argData );
                button:Show();
                button:Enable();
            else
                button:Hide();
            end;
        end;
    end;

-- Scroll function for frames registered
    function EventTracker_Scroll_Frames()
        local length = #ET_FrameInfo;
        local line, index, button;
        local offset = FauxScrollFrame_GetOffset( EventTracker_Frames );

        -- Update scrollbars
        FauxScrollFrame_Update( EventTracker_Frames, length+1, ET_FRAMES, 16 );

        -- Redraw items
        for line = 1, ET_FRAMES, 1 do
            index = offset + line;
            button = _G["EventFrame"..line];
            button:SetID( line );
            button:SetAttribute( "index", index );
            if index <= length then
                _G["EventFrame"..line.."InfoFrame"]:SetText( ( ET_FrameInfo[index]:GetName() or ET_UNNAMED_FRAME ) );
                button:Show();
                button:Enable();
            else
                button:Hide();
            end;
        end;
    end;

-- Update the UI
    function EventTracker_UpdateUI( currenttime )
        -- Number of events caught
        _G["EventCount"]:SetText( ET_EVENT_COUNT:format( #ET_EventDetail ) );

        -- Number of events that are being tracked
        _G["EventsTracked"]:SetText( ET_EVENTS_TRACKED:format( #ET_TRACKED_EVENTS ) );

        -- Memory usage
        _G["EventMemory"]:SetText( ET_MEMORY:format( GetAddOnMemoryUsage( "EventTracker" ) ) );

        -- Update tracking state
        _G["TrackingState"]:SetText( ET_TRACKING:format( lower( gsub( gsub( tostring( ET_Data["active"] ), "true", ET_STATE_ON ), "false", ET_STATE_OFF ) ) ) );

        -- Update current event for details
        if ( ET_CurrentEvent ) then
            _G["CurrentEventName"]:SetText( ET_CurrentEvent.." ["..ET_Events[ET_CurrentEvent].count.."]" );
            _G["EventTimeCurrent"]:SetText( ET_TIME_CURRENT:format( currenttime or 0 ) );
            _G["EventTimeTotal"]:SetText( ET_TIME_TOTAL:format( ET_Events[ET_CurrentEvent].time or 0 ) );
        else
            _G["CurrentEventName"]:SetText( ET_UNKNOWN );
            _G["EventTimeCurrent"]:SetText( ET_TIME_CURRENT:format( 0 ) );
            _G["EventTimeTotal"]:SetText( ET_TIME_TOTAL:format( 0 ) );
        end;
    end;

-- Toggle tracking
    function EventTracker_Toggle()
        ET_Data["active"] = not ET_Data["active"];
        EventTracker_UpdateUI();
    end;

-- Handle click on event item
    function EventTracker_EventOnClick( self, button, down )
        local event, timestamp, data, realevent, time_usage, call_stack = unpack( ET_EventDetail[ FauxScrollFrame_GetOffset( EventTracker_Details ) + self:GetID() ] );

        if ( IsShiftKeyDown() ) then
            EventTracker:UnregisterEvent( event );
            EventTracker_PurgeEvent( event );
            EventTracker_Message( "Event "..event.." has been removed" , true );
        else
            if ( button == "LeftButton" ) then
                if ( realevent ) then
                    ET_FrameInfo = { GetFramesRegisteredForEvent( event ) };
                    Event_Frame_FrameHeading:SetText( ET_REGISTERED_TEXT );
                    EventCallStack:SetText( "" );
                else
                    wipe( ET_FrameInfo );
                    Event_Frame_FrameHeading:SetText( ET_CALLSTACK_TEXT );
                    EventCallStack:SetText( call_stack );
                end;
                ET_ArgumentInfo = data;
                ET_CurrentEvent = event;
                EventTracker_Scroll_Arguments();
                EventTracker_Scroll_Frames();
                EventTracker_UpdateUI( time_usage );

                -- Show the detail window if not already showing
                if ( not EventDetailFrame:IsVisible() ) then
                    EventTracker_Toggle_Details();
                end;
            end;
        end;
    end;

-- Show help message
    function EventTracker_ShowHelp()
        for key, value in pairs( ET_HELP ) do
            EventTracker_Message( value );
        end;
    end;
    
    local function keys(t)
        if not t then return end
        local result = {}
        for k,v in pairs(t) do
            tinsert(result, k)
        end
        return result
    end
    
    local function listEvents()
        local events
        if ET_Data and ET_Data["events"] then 
            events = keys(ET_Data["events"])
        end
        
        if not events or getn(events) < 1 then
            EventTracker_Message(
                "The list of additional tracked events is empty.", true)
            return
        end
        
        table.sort(events)
        
        EventTracker_Message("Additional tracked events:", true)
        for i, v in ipairs(events) do
            EventTracker_Message("  " .. v)
        end
    end
    
    local function showFilter()
        if ET_FILTER then
            EventTracker_Message(format("Filter: '%s'", tostring(ET_FILTER)), 
                true)
        else
            EventTracker_Message("No event filter.", true)
        end
    end

-- Handle slash commands
    function EventTracker_SlashHandler( msg, editbox )
        -- arguments should be handled case-insensitve
        local command, event = strsplit( " ", msg );

        command = strlower( command or "" );
        event = strtrim( strupper( event or "" ) );

        -- Handle each individual argument
        if ( command == "" ) then
            -- Show main dialog
            EventTracker_Toggle_Main();

        elseif ( command == "resetpos" ) then
            EventTrackerFrame:ClearAllPoints();
            EventTrackerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);

        elseif ( command == "add" and event ~= "" ) then
            -- Add event to be tracked
            EventTracker:RegisterEvent( event );
            local events = ET_Data["events"]
            events[event] = true

        elseif ( (command == "remove" or command == "del") and event ~= "" ) 
                then
            -- Remove event to be tracked
            EventTracker:UnregisterEvent( event );
            local events = ET_Data["events"]
            events[event] = nil
            
        elseif ( command == "list" ) then
            -- Show all additional tracked events in system chat
            listEvents()
            
        elseif ( command == "off" ) then
            -- Disable tracking
            ET_Data["active"] = false
            EventTracker_UpdateUI()

        elseif ( command == "on" ) then
            -- Enable tracking
            ET_Data["active"] = true
            EventTracker_UpdateUI()
            
        elseif ( command == "toggle" ) then
            -- Toggle event tracking
            EventTracker_Toggle()
            
        elseif ( command == "filter" ) then
            -- Set filter to be applied to registerall events
            if event == "" then
                showFilter()
            else
                ET_FILTER = event
            end
            
        elseif ( command == "removefilter" or command == "delfilter" ) then
            -- Remove the filter
            ET_FILTER = nil;
            
        elseif ( command == "purge" ) then
            -- Purge all event data
            EventTracker_Purge()
            
        elseif ( command == "registerall" ) then
            -- Track all events
            EventTracker:RegisterAllEvents();
            EventTracker_RemoveIgnoredEvents();
            ET_Data["events"] = {}
            
        elseif ( command == "unregisterall" ) then
            -- Track all events
            EventTracker:UnregisterAllEvents();
            EventTracker:RegisterEvent( "VARIABLES_LOADED" );
            ET_Data["events"] = {}
            
        elseif ( msg == "help" ) or ( msg == "?" ) then
            -- Show help info
            EventTracker_ShowHelp();
        end;
    end;