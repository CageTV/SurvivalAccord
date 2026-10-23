ScriptName SA_Firmament Hidden
{Survival Accord: Firmament's Exploration perks and effects applied to Last Seed (Hunger, Fatigue) and Frostfall (cold Exposure).
Every function returns the neutral value (1.0 or False) when Firmament is not installed, so these hooks cost nothing without it.}

; Local FormIDs inside FirmamentNewSkills.esp
; Resilience I-V = 16..20, Camper I-II = 22, 23, Field Rations I-II = 24, 25, Dungeon Delver = 26, Fortify Exploration equipment effect = 167.

Float Function ClampPercent(Float afValue) Global
	If afValue < 0.0
		Return 0.0
	ElseIf afValue > 100.0
		Return 100.0
	EndIf
	Return afValue
EndFunction

; ---------- Frostfall ----------

Float Function GetResiliencePercent(Actor akActor) Global
	If SurvivalAccordNative.HasFirmamentPerk(akActor, 20)
		Return 50.0
	ElseIf SurvivalAccordNative.HasFirmamentPerk(akActor, 19)
		Return 40.0
	ElseIf SurvivalAccordNative.HasFirmamentPerk(akActor, 18)
		Return 30.0
	ElseIf SurvivalAccordNative.HasFirmamentPerk(akActor, 17)
		Return 20.0
	ElseIf SurvivalAccordNative.HasFirmamentPerk(akActor, 16)
		Return 10.0
	EndIf
	Return 0.0
EndFunction

; Multiplier for Frostfall's cold Exposure gain: Resilience plus the Fortify Exploration equipment effects, summed, capped at 100%.
Float Function GetColdExposureMultiplier(Actor akActor) Global
	If !akActor || !SurvivalAccordNative.IsFirmamentLoaded()
		Return 1.0
	EndIf
	Float percent = SA_Firmament.GetResiliencePercent(akActor) + SurvivalAccordNative.GetFirmamentActiveEffectMagnitude(167)
	Return 1.0 - SA_Firmament.ClampPercent(percent) / 100.0
EndFunction

; ---------- Last Seed ----------

; Pathfinder: Firmament's ExplorationPotions value slows Hunger and Fatigue. Never below 1% of the normal rate.
Float Function GetPathfinderMultiplier(Actor akActor) Global
	If !akActor
		Return 1.0
	EndIf
	Float result = 1.0 - SA_Firmament.ClampPercent(akActor.GetActorValue("ExplorationPotions")) / 100.0
	If result < 0.01
		Return 0.01
	EndIf
	Return result
EndFunction

Bool Function HasDungeonDelver(Actor akActor) Global
	Return SurvivalAccordNative.HasFirmamentPerk(akActor, 26)
EndFunction

; Dungeon Delver halves Hunger and Fatigue while the player is in an interior whose location is a Last Seed dungeon.
Bool Function DungeonDelverActive(Actor akActor, Keyword akDungeonKeyword) Global
	If !akActor || !akDungeonKeyword || !SA_Firmament.HasDungeonDelver(akActor)
		Return False
	EndIf
	Cell here = akActor.GetParentCell()
	If !here || !here.IsInterior()
		Return False
	EndIf
	Location loc = akActor.GetCurrentLocation()
	If !loc
		Return False
	EndIf
	Return loc.HasKeyword(akDungeonKeyword)
EndFunction

; Pathfinder times Dungeon Delver: the factor both Hunger and Fatigue share.
Float Function GetNeedsMultiplier(Actor akActor, Keyword akDungeonKeyword) Global
	If !akActor || !SurvivalAccordNative.IsFirmamentLoaded()
		Return 1.0
	EndIf
	Float result = SA_Firmament.GetPathfinderMultiplier(akActor)
	If SA_Firmament.DungeonDelverActive(akActor, akDungeonKeyword)
		result *= 0.5
	EndIf
	Return result
EndFunction

Bool Function HasCamper(Actor akActor) Global
	Return SurvivalAccordNative.HasFirmamentPerk(akActor, 23) || SurvivalAccordNative.HasFirmamentPerk(akActor, 22)
EndFunction

; Camper I: Fatigue 20% slower, Camper II: 40% slower.
Float Function GetCamperFatigueMultiplier(Actor akActor) Global
	If SurvivalAccordNative.HasFirmamentPerk(akActor, 23)
		Return 0.6
	ElseIf SurvivalAccordNative.HasFirmamentPerk(akActor, 22)
		Return 0.8
	EndIf
	Return 1.0
EndFunction

; Camper: sleeping outdoors counts as a Well Rested sleep.
Bool Function CamperSleepsWellRested(Actor akActor) Global
	If !SA_Firmament.HasCamper(akActor)
		Return False
	EndIf
	Cell here = akActor.GetParentCell()
	Return here && !here.IsInterior()
EndFunction

; Field Rations I: food restores 1.5x Hunger, II: 2.0x. Hunger only, never Thirst.
Float Function GetFieldRationsMultiplier(Actor akActor) Global
	If SurvivalAccordNative.HasFirmamentPerk(akActor, 25)
		Return 2.0
	ElseIf SurvivalAccordNative.HasFirmamentPerk(akActor, 24)
		Return 1.5
	EndIf
	Return 1.0
EndFunction
