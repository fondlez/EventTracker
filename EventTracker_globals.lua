--[[ =================================================================
    Description:
        All globals used within EventTracker.
    ================================================================= --]]

-- Colors used within EventTracker
    C_BLUE   = "|cFF3366FF";
    C_RED    = "|cFFFF5533";
    C_YELLOW = "|cFFFFFF00";
    C_GREEN  = "|cFF00FF00";
    C_CLOSE  = "|r";

-- Global strings
    ET_NAME = GetAddOnMetadata( "EventTracker", "Title" );
    ET_VERSION = GetAddOnMetadata( "EventTracker", "Version" );
    ET_NAME_VERSION = ET_NAME.." - "..ET_VERSION;
    ET_STARTUP_MESSAGE = ET_NAME.." ("..C_GREEN..ET_VERSION..C_CLOSE..") loaded.";
    ET_NIL = "<"..C_RED.."nil"..C_CLOSE..">";
    ET_UNKNOWN = "***";

-- Data arrays
    ET_Events = {};
    ET_EventDetail = {};
    ET_FrameInfo = {};
    ET_ArgumentInfo = {};
    ET_CurrentEvent = nil;
    ET_ProcList = {};

-- Scroll frame
    ET_DETAILS = 10; -- Number of event lines
    ET_ARGUMENTS = 10; -- Number of argument lines
    ET_FRAMES = 7; -- Number of frame lines
    
-- Game version compatibility API
    ET_API = {}
    
    local function getClient()
        local display_version, build_number, build_date, ui_version 
            = GetBuildInfo()
        ui_version = ui_version or 11200
        return ui_version, display_version, build_number, build_date
    end

    local ui_version = getClient()
    local is_tbc = false
    if ui_version >= 20000 and ui_version <= 20400 then
        is_tbc = true
    end
    
    local FauxScrollFrame_OnVerticalScroll = FauxScrollFrame_OnVerticalScroll
    if not is_tbc then
        ET_API.tinsert = table.insert
        ET_API.wipe = table.wipe
        
        ET_API.FauxScrollFrame_OnVerticalScroll 
          = FauxScrollFrame_OnVerticalScroll
    else
        ET_API.tinsert = function( t, value )
            t[getn(t) + 1] = value
        end
        
        ET_API.wipe = function( t )
            local mt = getmetatable(t) or {}
            if not mt.__mode or mt.__mode ~= "kv" then
                mt.__mode = "kv"
                t = setmetatable(t, mt)
            end
            for k in pairs(t) do
                t[k] = nil
            end
            return t
        end
        
        ET_API.FauxScrollFrame_OnVerticalScroll = function( self, value, 
                itemHeight, updateFunction )
            FauxScrollFrame_OnVerticalScroll( itemHeight, updateFunction )
        end    
    end
    
    