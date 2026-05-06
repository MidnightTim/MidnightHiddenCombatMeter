-- MidnightHiddenCombatMeter
-- Hides Midnight (12.0) combat meters during combat and flags them NonInteractive.
-- Author: Generated for WoW 12.0 (Midnight)

local ADDON_NAME = "MidnightHiddenCombatMeter"

local addonEnabled = true   -- tracks whether hide-in-combat behaviour is active

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

-- All frames to target (parent + session window)
local METER_FRAMES = {
    "DamageMeter",
    "DamageMeterSessionWindow1",
}

local function SetNonInteractive(f, enable)
    if not f then return end
    if enable then
        f:EnableMouse(false)
        f:EnableMouseWheel(false)
    else
        f:EnableMouse(true)
        f:EnableMouseWheel(true)
    end
end

local function HideMeter()
    for _, name in ipairs(METER_FRAMES) do
        local f = _G[name]
        if f then
            if InCombatLockdown() then
                -- Hide() is blocked in combat on protected frames; use alpha trick instead
                f:SetAlpha(0)
            else
                f:Hide()
            end
            SetNonInteractive(f, true)
        end
    end
end

local function ShowMeter()
    for _, name in ipairs(METER_FRAMES) do
        local f = _G[name]
        if f then
            f:SetAlpha(1)
            if not InCombatLockdown() then
                f:Show()
            end
            SetNonInteractive(f, false)
        end
    end
end

-------------------------------------------------------------------------------
-- Event handling
-------------------------------------------------------------------------------

local frame = CreateFrame("Frame", ADDON_NAME .. "Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")   -- entering combat
frame:RegisterEvent("PLAYER_REGEN_ENABLED")    -- leaving combat

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON_NAME then
            -- If we log in while already in combat, hide immediately
            if InCombatLockdown() then
                HideMeter()
            end
        end

    elseif event == "PLAYER_REGEN_DISABLED" then
        if addonEnabled then HideMeter() end

    elseif event == "PLAYER_REGEN_ENABLED" then
        if addonEnabled then ShowMeter() end
    end
end)

-------------------------------------------------------------------------------
-- Slash command  /mhcm  (toggle / status)
-------------------------------------------------------------------------------

local function PrintStatus()
    local state  = addonEnabled and "|cff00ff00ON|r" or "|cffff4444OFF|r"
    local combat = InCombatLockdown() and "|cffff4444yes|r" or "|cff00ff00no|r"
    print("|cff00ccff[MHCM]|r Hide-in-combat: " .. state .. "  |  In combat: " .. combat)
    for _, name in ipairs(METER_FRAMES) do
        local f = _G[name]
        local vis = f and (f:IsShown() and "|cff00ff00visible|r" or "|cffff4444hidden|r") or "|cffffff00not found|r"
        local alpha = f and string.format("  alpha=%.0f", f:GetAlpha()) or ""
        print("  " .. name .. ": " .. vis .. alpha)
    end
end

SLASH_MHCM1 = "/mhcm"
SlashCmdList["MHCM"] = function(msg)
    msg = msg:lower():trim()
    if msg == "help" or msg == "" then
        print("|cff00ccff[MidnightHiddenCombatMeter]|r Commands:")
        print("  /mhcm            – show this help")
        print("  /mhcm status     – show current addon state")
        print("  /mhcm toggle     – enable/disable hide-in-combat")
        print("  /mhcm on         – enable hide-in-combat")
        print("  /mhcm off        – disable hide-in-combat")
        print("  /mhcm scan       – check if the known meter frames are loaded")
    elseif msg == "scan" then
        print("|cff00ccff[MHCM]|r Checking known meter frames...")
        for _, name in ipairs(METER_FRAMES) do
            local f = _G[name]
            if f then
                print("  |cff00ff00FOUND|r " .. name .. "  shown=" .. tostring(f:IsShown()) .. "  alpha=" .. f:GetAlpha())
            else
                print("  |cffff4444NOT FOUND|r " .. name)
            end
        end
    elseif msg == "status" then
        PrintStatus()
    elseif msg == "toggle" then
        addonEnabled = not addonEnabled
        if addonEnabled then
            print("|cff00ccff[MHCM]|r Hide-in-combat |cff00ff00ENABLED|r.")
            if InCombatLockdown() then HideMeter() end
        else
            print("|cff00ccff[MHCM]|r Hide-in-combat |cffff4444DISABLED|r. Meter restored.")
            ShowMeter()
        end
    elseif msg == "on" then
        addonEnabled = true
        print("|cff00ccff[MHCM]|r Hide-in-combat |cff00ff00ENABLED|r.")
        if InCombatLockdown() then HideMeter() end
    elseif msg == "off" then
        addonEnabled = false
        print("|cff00ccff[MHCM]|r Hide-in-combat |cffff4444DISABLED|r. Meter restored.")
        ShowMeter()
    elseif msg == "hide" then
        HideMeter()
        print("|cff00ccff[MHCM]|r Meter hidden and set NonInteractive.")
    elseif msg == "show" then
        ShowMeter()
        print("|cff00ccff[MHCM]|r Meter shown and set Interactive.")
    else
        print("|cff00ccff[MHCM]|r Unknown command. Type /mhcm for help.")
    end
end

print("|cff00ccff[MidnightHiddenCombatMeter]|r loaded. Type /mhcm for options.")
