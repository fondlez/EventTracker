--[[ =================================================================
    Description:
        Use this file to specify which events need to be tracked.
    ================================================================= --]]

-- Events to be tracked
    ET_TRACKED_EVENTS = {
        --"PLAYER_LEVEL_UP",
        --"PLAYER_XP_UPDATE",
        --"PLAYER_TARGET_CHANGED",
        --"CHAT_MSG_CHANNEL",
        --"PLAYER_EQUIPMENT_CHANGED",

        -- WoW 3.2 events
        --"UNIT_SPELLCAST_INTERRUPTIBLE",
        --"UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
        --"EQUIPMENT_SWAP_FINISHED",
    };
    
-- Events to be ignored (applied when using /registerall)
    ET_IGNORED_EVENTS = {
        --"CURSOR_UPDATE",
    };