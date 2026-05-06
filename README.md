# MidnightHiddenCombatMeter
Midnight Hidden Combat Meter
Hides the default Blizzard Damage Meter during combat — automatically.
The built-in Damage Meter introduced in Midnight (12.0) is great out of combat, but it's screen clutter when you're in the middle of a pull. This addon watches your combat state and hides the meter the moment you engage, then brings it back when the fight ends.
Commands
/mhcm toggle — enable or disable
/mhcm on / /mhcm off — explicit control
/mhcm status — see current state
/mhcm hide / /mhcm show — manual overrides
Notes
Works around WoW's combat lockdown restriction by using alpha rather than Hide() during active combat. Targets both DamageMeter and DamageMeterSessionWindow1 frames. No dependencies, no saved variables, minimal footprint.
