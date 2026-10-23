ScriptName _Seed_HungerSystem Extends _Seed_AttributeSystem

;-- Variables ---------------------------------------
Float REGEN_HUNGER_RATE = 0.5
Float lastHealth = 0.0

;-- Properties --------------------------------------
FormList Property AutoEatenFood Auto
ImageSpaceModifier Property HungerISM5 Auto
ImageSpaceModifier Property HungerISM6 Auto
Message Property HungerMessage1 Auto
Message Property HungerMessage2 Auto
Message Property HungerMessage3 Auto
Message Property HungerMessage4 Auto
Message Property HungerMessage5 Auto
Message Property HungerMessage6 Auto
Sound Property HungerSound3 Auto
Sound Property HungerSound4 Auto
Sound Property HungerSound5 Auto
Sound Property HungerSound6 Auto
Spell Property HungerSpell1 Auto
Spell Property HungerSpell2 Auto
Spell Property HungerSpell3 Auto
Spell Property HungerSpell4 Auto
Spell Property HungerSpell5 Auto
Spell Property HungerSpell6 Auto
GlobalVariable Property _Seed_DiseaseNeedsMulti_StomachRot Auto
Quest Property _Seed_HungerMeterQuest Auto
GlobalVariable Property _Seed_Setting_AutoConsume Auto
GlobalVariable Property _Seed_Setting_HungerMeterDisplayMode Auto
GlobalVariable Property _Seed_Setting_NeedsAffectedByRegeneration Auto
GlobalVariable Property _Seed_Setting_Notifications_Followers Auto
FormList Property recentlyEatenFood Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Function StartUp()
  debugSystemName = "Hunger" ; #DEBUG_LINE_NO:44
  meterUpdateEvent = "LastSeed_UpdateHungerMeter" ; #DEBUG_LINE_NO:45
  meterForceEvent = "LastSeed_ForceHungerMeterDisplay" ; #DEBUG_LINE_NO:46
  attributeSpells = new Spell[6] ; #DEBUG_LINE_NO:49
  attributeMessages = new Message[6] ; #DEBUG_LINE_NO:50
  attributeSoundsM = new Sound[6] ; #DEBUG_LINE_NO:51
  attributeSoundsF = new Sound[6] ; #DEBUG_LINE_NO:52
  attributeISMs = new ImageSpaceModifier[6] ; #DEBUG_LINE_NO:53
  attributeSpells[0] = HungerSpell1 ; #DEBUG_LINE_NO:56
  attributeSpells[1] = HungerSpell2 ; #DEBUG_LINE_NO:57
  attributeSpells[2] = HungerSpell3 ; #DEBUG_LINE_NO:58
  attributeSpells[3] = HungerSpell4 ; #DEBUG_LINE_NO:59
  attributeSpells[4] = HungerSpell5 ; #DEBUG_LINE_NO:60
  attributeSpells[5] = HungerSpell6 ; #DEBUG_LINE_NO:61
  attributeMessages[0] = HungerMessage1 ; #DEBUG_LINE_NO:63
  attributeMessages[1] = HungerMessage2 ; #DEBUG_LINE_NO:64
  attributeMessages[2] = HungerMessage3 ; #DEBUG_LINE_NO:65
  attributeMessages[3] = HungerMessage4 ; #DEBUG_LINE_NO:66
  attributeMessages[4] = HungerMessage5 ; #DEBUG_LINE_NO:67
  attributeMessages[5] = HungerMessage6 ; #DEBUG_LINE_NO:68
  attributeSoundsM[2] = HungerSound3 ; #DEBUG_LINE_NO:71
  attributeSoundsM[3] = HungerSound4 ; #DEBUG_LINE_NO:72
  attributeSoundsM[4] = HungerSound5 ; #DEBUG_LINE_NO:73
  attributeSoundsM[5] = HungerSound6 ; #DEBUG_LINE_NO:74
  attributeSoundsF[2] = HungerSound3 ; #DEBUG_LINE_NO:76
  attributeSoundsF[3] = HungerSound4 ; #DEBUG_LINE_NO:77
  attributeSoundsF[4] = HungerSound5 ; #DEBUG_LINE_NO:78
  attributeSoundsF[5] = HungerSound6 ; #DEBUG_LINE_NO:79
  Self.RegisterForEvents() ; #DEBUG_LINE_NO:81
  Self.IncreaseAttribute(0.01, -1.0) ; #DEBUG_LINE_NO:84
EndFunction

Function RegisterForEvents()
  If !Self.IsRunning() ; #DEBUG_LINE_NO:90
    Return  ; #DEBUG_LINE_NO:91
  EndIf
EndFunction

String Function getFollowerMessage(Int i)
  Return seedutil.GetTranslationHandler().GetFollowerHungerMessage(i) ; #DEBUG_LINE_NO:97
EndFunction

Function ApplyAttributeLevel(int level, bool isIncreasing, bool forceMeter = false, bool flashMeter = false, int rumbleLevel = 0, bool lowerIsWorse = false, bool bypassVitalityTargetUpdate = false)
  Parent.ApplyAttributeLevel(level, isIncreasing, forceMeter, flashMeter, rumbleLevel, lowerIsWorse, bypassVitalityTargetUpdate) ; #DEBUG_LINE_NO:103
  If isIncreasing && level > 1 ; #DEBUG_LINE_NO:106
    If Self.isPlayer() ; #DEBUG_LINE_NO:107
      seedutil.GetConsumeManager().Player_AutoEat(0) ; #DEBUG_LINE_NO:108
    Else
      seedutil.GetConsumeManagerFollowers().NPC_AutoEat(followerIndex, 0) ; #DEBUG_LINE_NO:111
    EndIf
  ElseIf level == 0 ; #DEBUG_LINE_NO:114
    seedutil.GetSkillTreeHandler().progressExperience() ; #DEBUG_LINE_NO:115
  EndIf
EndFunction

Function ChangeAttributeOverTime(bool suspendWhileSleeping = false, bool forceUpdate = false)
  Parent.ChangeAttributeOverTime(suspendWhileSleeping, forceUpdate) ; #DEBUG_LINE_NO:120
  recentlyEatenFood.Revert() ; #DEBUG_LINE_NO:123
  _seedinternal.SeedDebug(0, "Cleared the recently eaten food list.") ; #DEBUG_LINE_NO:124
EndFunction

Event OnUpdate()
  If Self.IsRunning() && _Seed_Setting_NeedsAffectedByRegeneration.getValueInt() == 2 ; #DEBUG_LINE_NO:133
    Bool regenerating = False ; #DEBUG_LINE_NO:134
    Float thisHealth = lastHealth ; #DEBUG_LINE_NO:135
    If Self.getActor() ; #DEBUG_LINE_NO:136
      thisHealth = Self.getActor().GetActorValue("Health") ; #DEBUG_LINE_NO:137
      If thisHealth > lastHealth ; #DEBUG_LINE_NO:138
        regenerating = True ; #DEBUG_LINE_NO:139
      EndIf
    EndIf
    If regenerating ; #DEBUG_LINE_NO:143
      Self.updateAttributeRegenerating(REGEN_HUNGER_RATE, _Seed_Setting_HungerMeterDisplayMode) ; #DEBUG_LINE_NO:144
      Self.RegisterForSingleUpdate(2 as Float) ; #DEBUG_LINE_NO:145
    Else
      Self.RegisterForSingleUpdate(5 as Float) ; #DEBUG_LINE_NO:147
    EndIf
    lastHealth = thisHealth ; #DEBUG_LINE_NO:149
  EndIf
EndEvent

Function showAttributeMessage(Int level)
  If Self.isPlayer() ; #DEBUG_LINE_NO:154
    If _Seed_Setting_Notifications.getValueInt() == 2 ; #DEBUG_LINE_NO:155
      If _Seed_Setting_AutoConsume.GetValue() == 2 as Float ; #DEBUG_LINE_NO:156
        seedutil.GetConsumeManager().EnqueuePlayerHungerMessage(attributeMessages[level]) ; #DEBUG_LINE_NO:157
      Else
        _seedinternal.SeedDebug(0, "[" + debugSystemName + "]: Showing message.") ; #DEBUG_LINE_NO:159
        attributeMessages[level].Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:160
      EndIf
    EndIf
  ElseIf Self.getFollowerMessage(level) ; #DEBUG_LINE_NO:163
    If _Seed_Setting_Notifications_Followers.getValueInt() == 2 ; #DEBUG_LINE_NO:164
      String name = "One of Your followers" ; #DEBUG_LINE_NO:165
      If camputil.GetSKSELoaded() ; #DEBUG_LINE_NO:166
        name = Self.getActor().GetBaseObject().GetName() ; #DEBUG_LINE_NO:167
      ElseIf followerIndex == 3 ; #DEBUG_LINE_NO:169
        name = "Your third follower" ; #DEBUG_LINE_NO:170
      ElseIf followerIndex == 2 ; #DEBUG_LINE_NO:171
        name = "Your second follower" ; #DEBUG_LINE_NO:172
      ElseIf followerIndex == 1 ; #DEBUG_LINE_NO:173
        name = "Your first follower" ; #DEBUG_LINE_NO:174
      EndIf
      seedutil.GetConsumeManagerFollowers().EnqueueFollowerHungerMessage(name + Self.getFollowerMessage(level), followerIndex) ; #DEBUG_LINE_NO:178
    EndIf
  EndIf
EndFunction

Function enqueueSound(Sound thisSound)
  seedutil.GetConsumeManager().EnqueuePlayerHungerSound(thisSound) ; #DEBUG_LINE_NO:185
EndFunction

Float Function GetAttributeMulti()
  Float result = 1 as Float ; #DEBUG_LINE_NO:190
  result += _Seed_DiseaseNeedsMulti_StomachRot.GetValue() ; #DEBUG_LINE_NO:191
  result *= attributeRateMultiGlobal.GetValue() ; #DEBUG_LINE_NO:192
  result *= Self.getCarriageRideMulti() ; #DEBUG_LINE_NO:194
  result *= Self.SA_FirmamentNeedsMulti() ; Survival Accord: Firmament Pathfinder and Dungeon Delver
  _seedinternal.SeedDebug(1, "[" + debugSystemName + "]: Attribute Multiplier: " + result as String) ; #DEBUG_LINE_NO:196
  Return result ; #DEBUG_LINE_NO:197
EndFunction

; Survival Accord: Firmament's Pathfinder (ExplorationPotions) and Dungeon Delver slow the Hunger rate. 1.0 when Firmament is not installed.
Float Function SA_FirmamentNeedsMulti()
  Return SA_Firmament.GetNeedsMultiplier(PlayerRef, seedutil.GetDiseaseSystem().LocTypeDungeon)
EndFunction

; Survival Accord: the base version applies the plain rate, so the delayed (menu / focus) cycles would skip the Firmament multiplier.
Function RunDelayedCycles()
  _seedinternal.SeedDebug(0, "[" + debugSystemName + "] Running delayed cycles.")
  Float thisRate = attributeRateGlobal.GetValue() * Self.SA_FirmamentNeedsMulti()
  Int totalCycles = delayedAttributeIncreaseIntervals
  _seedinternal.SeedDebug(1, (("[" + debugSystemName + "]: Updating, " + totalCycles as String) + " cycles (running delayed updates). Also updating " + attributeRegeneratingDelayed as String) + " pts from regeneration")
  Float attributeIncrease = (thisRate * totalCycles as Float) + attributeRegeneratingDelayed
  _seedinternal.SeedDebug(1, "[" + debugSystemName + "]: Total attribute increase: " + attributeIncrease as String)
  Self.IncreaseAttribute(attributeIncrease, -1.0)
  attributeRegeneratingDelayed = 0.0
  delayedAttributeIncreaseIntervals = 0
EndFunction
