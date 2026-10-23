ScriptName _Seed_PlayerEatMonitor Extends ReferenceAlias

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Potion Property DLC1BloodPotion Auto
Potion Property DLC1RedwaterDenSkooma Auto
GlobalVariable Property LastSeedRunning Auto
Actor Property PlayerRef Auto
Keyword Property VendorItemFood Auto
Keyword Property VendorItemFoodRaw Auto
FormList Property _Seed_BloodPotions Auto
FormList Property _Seed_DrinkAlcoholicAle Auto
FormList Property _Seed_DrinkAlcoholicSpirit Auto
FormList Property _Seed_DrinkAlcoholicWine Auto
FormList Property _Seed_DrinkSkoomaStrong Auto
FormList Property _Seed_DrinkSkoomaWeak Auto
FormList Property _Seed_Food_RestoreHungerMajor Auto
FormList Property _Seed_Food_RestoreHungerMassive Auto
FormList Property _Seed_Food_RestoreHungerMinor Auto
FormList Property _Seed_Food_RestoreHungerSuperior Auto
FormList Property _Seed_ForceFoodPortioning Auto
GlobalVariable Property _Seed_HelpDone_Alcohol Auto
GlobalVariable Property _Seed_HelpDone_DangerousFood Auto
GlobalVariable Property _Seed_HelpDone_Food Auto
GlobalVariable Property _Seed_HelpDone_SkoomaDrank Auto
GlobalVariable Property _Seed_HelpDone_Stew Auto
GlobalVariable Property _Seed_HelpDone_Variety Auto
Message Property _Seed_Help_Alcohol Auto
Message Property _Seed_Help_DangerousFood Auto
Message Property _Seed_Help_Food Auto
Message Property _Seed_Help_SkoomaDrank Auto
Message Property _Seed_Help_Stew Auto
Message Property _Seed_Help_Variety Auto
FormList Property _Seed_PortionsToProvisionsList Auto
GlobalVariable Property _Seed_ProvisionsAddPortions Auto
ObjectReference Property _Seed_ProvisionsContainerRef Auto
FormList Property _Seed_RecentlyEatenFood Auto
GlobalVariable Property _Seed_RestoreHungerMajorAmount Auto
GlobalVariable Property _Seed_RestoreHungerMassiveAmount Auto
GlobalVariable Property _Seed_RestoreHungerMinorAmount Auto
GlobalVariable Property _Seed_RestoreHungerSuperiorAmount Auto
GlobalVariable Property _Seed_RestoreThirstMajorAmount Auto
GlobalVariable Property _Seed_SaltIncreaseThirstAmount Auto
FormList Property _Seed_Salted Auto
GlobalVariable Property _Seed_SettingPlayerIsLich Auto
GlobalVariable Property _Seed_SettingVampireMonitoring Auto
GlobalVariable Property _Seed_Setting_DiminishingFoodReturns Auto
GlobalVariable Property _Seed_Setting_DisplayTutorials Auto
GlobalVariable Property _Seed_Setting_FoodPortioning Auto

;-- Functions ---------------------------------------

; Skipped compiler generated GetState

; Skipped compiler generated GotoState

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
  If LastSeedRunning.GetValueInt() == 2 ; #DEBUG_LINE_NO:96
    If _Seed_BloodPotions.HasForm(akBaseObject) && seedutil.getMonsterHandler().getVampireSettings(False, True, True) ; #DEBUG_LINE_NO:98
      seedutil.getMonsterHandler().vampireFeed() ; #DEBUG_LINE_NO:99
    ElseIf seedutil.IsFood(akBaseObject) ; #DEBUG_LINE_NO:100
      Bool animateEat = False ; #DEBUG_LINE_NO:102
      Bool animateDrink = False ; #DEBUG_LINE_NO:103
      Potion theFood = akBaseObject as Potion ; #DEBUG_LINE_NO:106
      If !seedutil.IsKnownFood(theFood as Form, False, True) ; #DEBUG_LINE_NO:107
        seedutil.GetCustomiseFoodHandler().classifyFood(theFood) ; #DEBUG_LINE_NO:108
      EndIf
      Int foodType = seedutil.GetFoodType(theFood) ; #DEBUG_LINE_NO:111
      Potion multiPart = seedutil.GetFoodDatastoreHandler().GetMultiPartFoodResult_Array(theFood, True) ; #DEBUG_LINE_NO:114
      If multiPart ; #DEBUG_LINE_NO:115
        Int aiCount = seedutil.GetFoodDatastoreHandler().GetMultiPartFoodQuantity_Array(theFood) ; #DEBUG_LINE_NO:116
        _seedinternal.SeedDebug(0, (("[_Seed_PlayerEatMonitor] Found Multi-Part food - " + theFood as String) + " -> " + multiPart as String) + " x " + aiCount as String) ; #DEBUG_LINE_NO:117
        Bool abSilent = False ; #DEBUG_LINE_NO:118
        If multiPart == theFood && aiCount == 1 ; #DEBUG_LINE_NO:119
          abSilent = True ; #DEBUG_LINE_NO:120
        EndIf
        Bool listHasFood = _Seed_PortionsToProvisionsList.Find(theFood as Form) != -1 ; #DEBUG_LINE_NO:122
        If _Seed_ProvisionsAddPortions.GetValueInt() == 2 || listHasFood ; #DEBUG_LINE_NO:123
          _seedinternal.SeedDebug(0, "[_Seed_PlayerEatMonitor] Adding Portions to provisions Container") ; #DEBUG_LINE_NO:124
          _Seed_ProvisionsContainerRef.AddItem(multiPart as Form, aiCount, abSilent) ; #DEBUG_LINE_NO:125
          If listHasFood ; #DEBUG_LINE_NO:126
            _Seed_PortionsToProvisionsList.RemoveAddedForm(theFood as Form) ; #DEBUG_LINE_NO:127
          EndIf
        Else
          _seedinternal.SeedDebug(0, "[_Seed_PlayerEatMonitor] Adding Portions to Player") ; #DEBUG_LINE_NO:130
          PlayerRef.AddItem(multiPart as Form, aiCount, abSilent) ; #DEBUG_LINE_NO:131
        EndIf
        If addMultiPart ; #DEBUG_LINE_NO:135
          _Seed_RecentlyEatenFood.AddForm(multiPart as Form) ; #DEBUG_LINE_NO:136
        EndIf
      Else
        _seedinternal.SeedDebug(0, "[_Seed_PlayerEatMonitor] Found non-multiPart Food " + theFood as String) ; #DEBUG_LINE_NO:139
      EndIf
      If _Seed_SettingPlayerIsLich.getValue() == 2 as Float ; #DEBUG_LINE_NO:143
        Return  ; #DEBUG_LINE_NO:144
      EndIf
      Float amountToRestore = seedutil.GetFoodDatastoreHandler().getFoodRestoreAmount(theFood as Form) ; #DEBUG_LINE_NO:147
      Float diseaseChance = seedutil.getDiseaseChanceFloat(akBaseObject, PlayerRef) ; #DEBUG_LINE_NO:163
      If diseaseChance > 0 as Float ; #DEBUG_LINE_NO:164
        Self.ShowTutorial_DangerousFood() ; #DEBUG_LINE_NO:165
        seedutil.catchRandomDisease(diseaseChance, False) ; #DEBUG_LINE_NO:166
      EndIf
      If foodType == 18 && seedutil.getMonsterHandler().getVampireSettings(False, False, True) == False ; #DEBUG_LINE_NO:170
        If _Seed_DrinkAlcoholicAle.HasForm(akBaseObject) ; #DEBUG_LINE_NO:171
          Self.ShowTutorial_Alcohol() ; #DEBUG_LINE_NO:172
          seedutil.AlcoholConsumed(1) ; #DEBUG_LINE_NO:173
          Self.addStrongBrew(1) ; #DEBUG_LINE_NO:174
        ElseIf _Seed_DrinkAlcoholicWine.HasForm(akBaseObject) ; #DEBUG_LINE_NO:175
          Self.ShowTutorial_Alcohol() ; #DEBUG_LINE_NO:176
          seedutil.AlcoholConsumed(2) ; #DEBUG_LINE_NO:177
          Self.addStrongBrew(2) ; #DEBUG_LINE_NO:178
        ElseIf _Seed_DrinkAlcoholicSpirit.HasForm(akBaseObject) ; #DEBUG_LINE_NO:179
          Self.ShowTutorial_Alcohol() ; #DEBUG_LINE_NO:180
          seedutil.AlcoholConsumed(3) ; #DEBUG_LINE_NO:181
          Self.addStrongBrew(3) ; #DEBUG_LINE_NO:182
        ElseIf _Seed_DrinkSkoomaWeak.HasForm(akBaseObject) ; #DEBUG_LINE_NO:183
          Self.ShowTutorial_Skooma() ; #DEBUG_LINE_NO:184
          seedutil.SkoomaConsumed(1) ; #DEBUG_LINE_NO:185
        ElseIf _Seed_DrinkSkoomaStrong.HasForm(akBaseObject) ; #DEBUG_LINE_NO:186
          Self.ShowTutorial_Skooma() ; #DEBUG_LINE_NO:187
          seedutil.SkoomaConsumed(2) ; #DEBUG_LINE_NO:188
        EndIf
        If akBaseObject == DLC1RedwaterDenSkooma as Form ; #DEBUG_LINE_NO:190
          seedutil.GetSkoomaSystem().becomeAddicted() ; #DEBUG_LINE_NO:191
        EndIf
      EndIf
      If seedutil.GetThirstSystem().isRunning() && seedutil.getMonsterHandler().getVampireSettings(False, True, True) == False ; #DEBUG_LINE_NO:196
        If foodType == 15 || foodType == 17 || foodType == 19 || foodType == 18 && !_Seed_DrinkSkoomaWeak.HasForm(akBaseObject) && !_Seed_DrinkSkoomaStrong.HasForm(akBaseObject) ; #DEBUG_LINE_NO:197
          _seedinternal.SeedDebug(0, "Restoring thirst") ; #DEBUG_LINE_NO:198
          seedutil.RestorePlayerThirst(_Seed_RestoreThirstMajorAmount.getValue(), -1.0) ; #DEBUG_LINE_NO:199
          If foodType != 15 ; #DEBUG_LINE_NO:200
            animateDrink = True ; #DEBUG_LINE_NO:201
          EndIf
        EndIf
        If _Seed_Salted.HasForm(akBaseObject) ; #DEBUG_LINE_NO:205
          seedutil.GetThirstSystem().IncreaseAttribute(amountToRestore / 4 as Float, -1.0) ; #DEBUG_LINE_NO:206
        EndIf
      EndIf
      Bool addMultiPart = False ; #DEBUG_LINE_NO:214
      If (amountToRestore > 0 as Float) && seedutil.GetHungerSystem().isRunning() ; #DEBUG_LINE_NO:215
        If seedutil.getMonsterHandler().getVampireSettings(False, True, True) == False ; #DEBUG_LINE_NO:216
          Self.ShowTutorial_Food() ; #DEBUG_LINE_NO:217
          If _Seed_Setting_DiminishingFoodReturns.GetValueInt() == 2 ; #DEBUG_LINE_NO:218
            If _Seed_RecentlyEatenFood.HasForm(theFood as Form) ; #DEBUG_LINE_NO:219
              _seedinternal.SeedDebug(0, "This food was recently eaten.") ; #DEBUG_LINE_NO:220
              amountToRestore *= 0.5 ; #DEBUG_LINE_NO:221
              Self.ShowTutorial_Variety() ; #DEBUG_LINE_NO:222
            Else
              _seedinternal.SeedDebug(0, "This food was not recently eaten.") ; #DEBUG_LINE_NO:224
              _Seed_RecentlyEatenFood.AddForm(theFood as Form) ; #DEBUG_LINE_NO:225
              addMultiPart = True ; #DEBUG_LINE_NO:227
            EndIf
          EndIf
          animateEat = True ; #DEBUG_LINE_NO:230
          Float saHungerRestore = amountToRestore * SA_Firmament.GetFieldRationsMultiplier(PlayerRef) ; Survival Accord: Firmament Field Rations
          _seedinternal.SeedDebug(1, ("Restoring " + saHungerRestore as String) + " hunger.")
          seedutil.RestorePlayerHunger(saHungerRestore, -1.0)
        ElseIf seedutil.getMonsterHandler().getVampireSettings(True, True, False) && (foodType == 2 || foodType == 4) ; #DEBUG_LINE_NO:235
          seedutil.RestorePlayerHunger(amountToRestore * SA_Firmament.GetFieldRationsMultiplier(PlayerRef), 41.0) ; #DEBUG_LINE_NO:236
          seedutil.RestorePlayerThirst(amountToRestore, 41.0) ; #DEBUG_LINE_NO:237
        EndIf
      EndIf
      If foodType == 15 ; #DEBUG_LINE_NO:242
        Self.ShowTutorial_Stew() ; #DEBUG_LINE_NO:243
        Self.addHeartyMeal() ; #DEBUG_LINE_NO:244
      EndIf
      If animateEat ; #DEBUG_LINE_NO:250
        seedutil.GetConsumeManager().enqueuePlayerEatAnimation() ; #DEBUG_LINE_NO:251
      ElseIf animateDrink
        seedutil.GetConsumeManager().enqueuePlayerDrinkAnimation() ; #DEBUG_LINE_NO:253
      EndIf
    Else
      _seedinternal.SeedDebug(0, ("Object was not food. Reason: Was Potion " + (akBaseObject as Potion) as String) + ", HasKeyword(VendorItemFood || VendorItemFoodRaw) " + (akBaseObject.HasKeyword(VendorItemFood) || akBaseObject.HasKeyword(VendorItemFoodRaw)) as String) ; #DEBUG_LINE_NO:256
    EndIf
  EndIf
EndEvent

Function ShowTutorial_Variety()
  If _Seed_Setting_DisplayTutorials.GetValueInt() == 2 && _Seed_HelpDone_Variety.GetValueInt() == 1 ; #DEBUG_LINE_NO:263
    _Seed_Help_Variety.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:264
    _Seed_HelpDone_Variety.SetValue(2 as Float) ; #DEBUG_LINE_NO:265
  EndIf
EndFunction

Function ShowTutorial_Alcohol()
  If _Seed_Setting_DisplayTutorials.GetValueInt() == 2 && _Seed_HelpDone_Alcohol.GetValueInt() == 1 ; #DEBUG_LINE_NO:269
    _Seed_Help_Alcohol.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:270
    _Seed_HelpDone_Alcohol.SetValue(2 as Float) ; #DEBUG_LINE_NO:271
  EndIf
EndFunction

Function ShowTutorial_Skooma()
  If _Seed_Setting_DisplayTutorials.GetValueInt() == 2 && _Seed_HelpDone_SkoomaDrank.GetValueInt() == 1 ; #DEBUG_LINE_NO:275
    _Seed_Help_SkoomaDrank.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:276
    _Seed_HelpDone_SkoomaDrank.SetValue(2 as Float) ; #DEBUG_LINE_NO:277
  EndIf
EndFunction

Function ShowTutorial_Food()
  If _Seed_Setting_DisplayTutorials.GetValueInt() == 2 && _Seed_HelpDone_Food.GetValueInt() == 1 ; #DEBUG_LINE_NO:281
    _Seed_Help_Food.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:282
    _Seed_HelpDone_Food.SetValue(2 as Float) ; #DEBUG_LINE_NO:283
  EndIf
EndFunction

Function ShowTutorial_Stew()
  If _Seed_Setting_DisplayTutorials.GetValueInt() == 2 && _Seed_HelpDone_Stew.GetValueInt() == 1 ; #DEBUG_LINE_NO:287
    _Seed_Help_Stew.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:288
    _Seed_HelpDone_Stew.SetValue(2 as Float) ; #DEBUG_LINE_NO:289
  EndIf
EndFunction

Function ShowTutorial_DangerousFood()
  If _Seed_Setting_DisplayTutorials.GetValueInt() == 2 && _Seed_HelpDone_DangerousFood.GetValueInt() == 1 ; #DEBUG_LINE_NO:293
    _Seed_Help_DangerousFood.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:294
    _Seed_HelpDone_DangerousFood.SetValue(2 as Float) ; #DEBUG_LINE_NO:295
  EndIf
EndFunction

Function restoreExposure(Float amountToRestore)
  _seed_compatibility compatibility = seedutil.GetCompatibilitySystem() ; #DEBUG_LINE_NO:302
  If !compatibility.isFrostfallLoaded ; #DEBUG_LINE_NO:303
    Return  ; #DEBUG_LINE_NO:304
  EndIf
  If frostutil.IsPlayerNearFire() ; #DEBUG_LINE_NO:307
    frostutil.ModPlayerExposure(amountToRestore, -1.0) ; #DEBUG_LINE_NO:308
  EndIf
EndFunction

Function addHeartyMeal()
  _seed_compatibility compatibility = seedutil.GetCompatibilitySystem() ; #DEBUG_LINE_NO:313
  If !compatibility.isFrostfallLoaded ; #DEBUG_LINE_NO:314
    If frostutil.GetPlayerExposureLevel() > 1 ; #DEBUG_LINE_NO:315
      Potion heartyMeal = Self.getHeartyMeal() ; #DEBUG_LINE_NO:316
      If heartyMeal ; #DEBUG_LINE_NO:317
        PlayerRef.AddItem(heartyMeal as Form, 1, True) ; #DEBUG_LINE_NO:318
        PlayerRef.EquipItem(heartyMeal as Form, False, True) ; #DEBUG_LINE_NO:319
      EndIf
    EndIf
  EndIf
EndFunction

Function addStrongBrew(Int strength)
  _seed_compatibility compatibility = seedutil.GetCompatibilitySystem() ; #DEBUG_LINE_NO:327
  If !compatibility.isFrostfallLoaded ; #DEBUG_LINE_NO:328
    If frostutil.GetPlayerExposureLevel() > 1 ; #DEBUG_LINE_NO:329
      Potion strongBrew
      If strength == 1 ; #DEBUG_LINE_NO:331
        strongBrew = Self.getStrongBrew1() ; #DEBUG_LINE_NO:332
      ElseIf strength == 2 ; #DEBUG_LINE_NO:333
        strongBrew = Self.getStrongBrew2() ; #DEBUG_LINE_NO:334
      ElseIf strength == 3 ; #DEBUG_LINE_NO:335
        strongBrew = Self.getStrongBrew3() ; #DEBUG_LINE_NO:336
      EndIf
      If strongBrew ; #DEBUG_LINE_NO:339
        PlayerRef.AddItem(strongBrew as Form, 1, True) ; #DEBUG_LINE_NO:340
        PlayerRef.EquipItem(strongBrew as Form, False, True) ; #DEBUG_LINE_NO:341
      EndIf
    EndIf
  EndIf
EndFunction

Bool Function isFrostfallFood(Potion theFood)
  _seedinternal.SeedDebug(0, "[_Seed_PlayerEatMonitor] Checking if Frostfall Food: " + theFood as String) ; #DEBUG_LINE_NO:350
  If theFood ; #DEBUG_LINE_NO:351
    If theFood == Self.getHeartyMeal() ; #DEBUG_LINE_NO:352
      Return True ; #DEBUG_LINE_NO:353
    ElseIf theFood == Self.getStrongBrew1() ; #DEBUG_LINE_NO:354
      Return True ; #DEBUG_LINE_NO:355
    ElseIf theFood == Self.getStrongBrew2() ; #DEBUG_LINE_NO:356
      Return True ; #DEBUG_LINE_NO:357
    ElseIf theFood == Self.getStrongBrew3() ; #DEBUG_LINE_NO:358
      Return True ; #DEBUG_LINE_NO:359
    EndIf
  EndIf
  Return False ; #DEBUG_LINE_NO:362
EndFunction

Potion Function getHeartyMeal()
  Return Self.getFrostfallFood(420703, "_Frost_FoodEffectPotion") ; #DEBUG_LINE_NO:367
EndFunction

Potion Function getStrongBrew1()
  Return Self.getFrostfallFood(118461, "_Frost_DrinkEffectPotion1") ; #DEBUG_LINE_NO:370
EndFunction

Potion Function getStrongBrew2()
  Return Self.getFrostfallFood(118463, "_Frost_DrinkEffectPotion2") ; #DEBUG_LINE_NO:373
EndFunction

Potion Function getStrongBrew3()
  Return Self.getFrostfallFood(118465, "_Frost_DrinkEffectPotion3") ; #DEBUG_LINE_NO:376
EndFunction

Potion Function getFrostfallFood(Int aiFormID, String foodName)
  _seed_compatibility compatibility = seedutil.GetCompatibilitySystem() ; #DEBUG_LINE_NO:380
  If !compatibility.isFrostfallLoaded ; #DEBUG_LINE_NO:381
    _seedinternal.SeedDebug(0, "[_Seed_PlayerEatMonitor] Frostfall is not loaded") ; #DEBUG_LINE_NO:382
    Return None ; #DEBUG_LINE_NO:383
  EndIf
  Potion result = Game.GetFormFromFile(aiFormID, "Frostfall.esp") as Potion ; #DEBUG_LINE_NO:386
  If result == None ; #DEBUG_LINE_NO:387
    _seedinternal.SeedDebug(3, "[_Seed_PlayerEatMonitor] ERRROR: " + foodName + " not found in frostfall.esp") ; #DEBUG_LINE_NO:388
  EndIf
  Return result ; #DEBUG_LINE_NO:390
EndFunction
