ScriptName SurvivalAccordNative Hidden
{Native functions of SurvivalAccord.dll. Every function is safe to call when Firmament is not installed: it returns False / 0.}

; True when Firmament (FirmamentNewSkills.esp) is in the load order.
Bool Function IsFirmamentLoaded() Global Native

; True when the actor has the Firmament perk with this local FormID (the ID inside FirmamentNewSkills.esp).
Bool Function HasFirmamentPerk(Actor akActor, Int aiLocalFormID) Global Native

; The summed magnitude of the player's active effects whose base effect is this Firmament magic effect
; (local FormID inside FirmamentNewSkills.esp). Used for Firmament's Fortify Exploration equipment enchantment.
Float Function GetFirmamentActiveEffectMagnitude(Int aiLocalFormID) Global Native

; Hunterborn support is planned: returns "coming soon" for now, and "Hunterborn found" in the log when the mod is installed.
String Function GetHunterbornStatus() Global Native
