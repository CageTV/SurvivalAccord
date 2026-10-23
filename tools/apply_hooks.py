"""Applies the Survival Accord hooks to the four Last Seed 2026 / Frostfall 2026 scripts in src/scripts.

The base files are copied once from E:/WorkSpace/Last-Seed-2026 (Fatigue: our source; Hunger and PlayerEatMonitor: Last Seed's own scripts
decompiled with Champollion) and E:/WorkSpace/Frostfall-2026-repo (ExposureSystem). This script is idempotent: it refuses to run on a file
that already carries a hook, so run it only on fresh copies (tools/refresh_base.py does the copy).
"""
import os
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(HERE, "src", "scripts")


def load(name):
    with open(os.path.join(SRC, name), "r", encoding="utf-8", newline="") as f:
        return f.read().replace("\r\n", "\n")


def save(name, text):
    with open(os.path.join(SRC, name), "w", encoding="utf-8", newline="") as f:
        f.write(text.replace("\n", "\r\n"))


def sub(text, old, new, label):
    if text.count(old) != 1:
        sys.exit(f"{label}: expected exactly one match, found {text.count(old)}")
    return text.replace(old, new)


def guard(text, name):
    if "SA_Firmament" in text:
        sys.exit(f"{name} already has Survival Accord hooks")


# ---------- Hunger ----------
name = "_Seed_HungerSystem.psc"
t = load(name)
guard(t, name)
t = sub(t, """  result *= Self.getCarriageRideMulti() ; #DEBUG_LINE_NO:194
  _seedinternal.SeedDebug(1, "[" + debugSystemName + "]: Attribute Multiplier: " + result as String) ; #DEBUG_LINE_NO:196
  Return result ; #DEBUG_LINE_NO:197
EndFunction
""", """  result *= Self.getCarriageRideMulti() ; #DEBUG_LINE_NO:194
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
""", name)
save(name, t)

# ---------- Eat monitor ----------
name = "_Seed_PlayerEatMonitor.psc"
t = load(name)
guard(t, name)
t = sub(t, """          _seedinternal.SeedDebug(1, ("Restoring " + amountToRestore as String) + " hunger.") ; #DEBUG_LINE_NO:231
          seedutil.RestorePlayerHunger(amountToRestore, -1.0) ; #DEBUG_LINE_NO:232""", """          Float saHungerRestore = amountToRestore * SA_Firmament.GetFieldRationsMultiplier(PlayerRef) ; Survival Accord: Firmament Field Rations
          _seedinternal.SeedDebug(1, ("Restoring " + saHungerRestore as String) + " hunger.")
          seedutil.RestorePlayerHunger(saHungerRestore, -1.0)""", name)
t = sub(t, """          seedutil.RestorePlayerHunger(amountToRestore, 41.0)""", """          seedutil.RestorePlayerHunger(amountToRestore * SA_Firmament.GetFieldRationsMultiplier(PlayerRef), 41.0)""", name)
save(name, t)

# ---------- Fatigue (our Last Seed 2026 source, tab indented) ----------
name = "_Seed_FatigueSystem.psc"
t = load(name)
guard(t, name)
t = sub(t, "(!IsRefInInterior(PlayerRef) && !PlayerIsCamping() && Provisioning_PerkRank_Outdoorsman.getValue() == 0))",
        "(!IsRefInInterior(PlayerRef) && !PlayerIsCamping() && !SA_Firmament.HasCamper(PlayerRef) && Provisioning_PerkRank_Outdoorsman.getValue() == 0))", name + " location")
t = sub(t, "ElseIf PlayerRef.GetCurrentLocation().HasKeyword(LocTypeInn) == True || PlayerRef.GetCurrentLocation().HasKeyword(LocTypePlayerHouse) == True\n",
        "ElseIf PlayerRef.GetCurrentLocation().HasKeyword(LocTypeInn) == True || PlayerRef.GetCurrentLocation().HasKeyword(LocTypePlayerHouse) == True || SA_Firmament.CamperSleepsWellRested(PlayerRef)\n", name + " well rested")
t = sub(t, "\tresult = result * getCarriageRideMulti()\n\t\n\tSeedDebug(1, \"[\" + debugSystemName + \"]: Attribute Multiplier: \" + result)\n\treturn result\nEndFunction\n",
        "\tresult = result * getCarriageRideMulti()\n\tresult = result * SA_FirmamentFatigueMulti() ; Survival Accord: Firmament Camper, Pathfinder and Dungeon Delver\n\t\n\tSeedDebug(1, \"[\" + debugSystemName + \"]: Attribute Multiplier: \" + result)\n\treturn result\nEndFunction\n"
        "\n; Survival Accord: Camper, Pathfinder and Dungeon Delver slow the Fatigue rate. 1.0 when Firmament is not installed.\n"
        "float function SA_FirmamentFatigueMulti()\n\treturn SA_Firmament.GetCamperFatigueMultiplier(PlayerRef) * SA_Firmament.GetNeedsMultiplier(PlayerRef, GetDiseaseSystem().LocTypeDungeon)\nendFunction\n"
        "\n; Survival Accord: the base version applies the plain rate, so the delayed (menu / focus) cycles would skip the Firmament multipliers.\n"
        "function RunDelayedCycles()\n\tSeedDebug(0, \"[\" + debugSystemName + \"] Running delayed cycles.\")\n\tfloat thisRate = attributeRateGlobal.GetValue() * SA_FirmamentFatigueMulti()\n\tint totalCycles = delayedAttributeIncreaseIntervals\n"
        "\tSeedDebug(1, \"[\" + debugSystemName + \"]: Updating, \" + totalCycles + \" cycles (running delayed updates). Also updating \" + attributeRegeneratingDelayed + \" pts from regeneration\")\n"
        "\tfloat attributeIncrease = (thisRate * totalCycles) + attributeRegeneratingDelayed\n\tSeedDebug(1, \"[\" + debugSystemName + \"]: Total attribute increase: \" + attributeIncrease)\n"
        "\tIncreaseAttribute(attributeIncrease)\n\tattributeRegeneratingDelayed = 0\n\tdelayedAttributeIncreaseIntervals = 0\nendFunction\n", name + " multiplier")
save(name, t)

# ---------- Frostfall exposure (our Frostfall 2026 source, tab indented) ----------
name = "_Frost_ExposureSystem.psc"
t = load(name)
guard(t, name)
t = sub(t, "\tif game_hours_passed >= 1.0\n\t\tfloat duration_amount = (target / 4) * game_hours_passed\n\t\tif target > EXPOSURE_LEVEL_4\n\t\t\ttarget = EXPOSURE_LEVEL_4\n\t\tendif\n\t\tModAttributeExposure(duration_amount, target, allow_skill_advancement=false)\n\telse\n\t\tModAttributeExposure(amount, target)\n\tendif\nendFunction\n",
        "\t; Survival Accord: Firmament Resilience and Fortify Exploration slow the cold exposure gain (1.0 when Firmament is not installed). Warming is not touched.\n"
        "\tfloat sa_cold = SA_Firmament.GetColdExposureMultiplier(PlayerRef)\n"
        "\tif game_hours_passed >= 1.0\n\t\tfloat duration_amount = (target / 4) * game_hours_passed * sa_cold\n\t\tif target > EXPOSURE_LEVEL_4\n\t\t\ttarget = EXPOSURE_LEVEL_4\n\t\tendif\n\t\tModAttributeExposure(duration_amount, target, allow_skill_advancement=false)\n\telse\n\t\tModAttributeExposure(amount * sa_cold, target)\n\tendif\nendFunction\n", name)
# The ESL build of Frostfall remaps this FormID (0x095012 -> 0x000C55); looking the keyword up by EditorID works for both builds.
t = sub(t, "\t\tinsulated_tent_keyword = Game.GetFormFromFile(0x095012, \"Frostfall.esp\") as Keyword\n",
        "\t\tinsulated_tent_keyword = Keyword.GetKeyword(\"_Frost_isInsulatedTent\") ; Survival Accord: by EditorID, the same in the regular and the ESL build of Frostfall 2026\n"
        "\t\tif !insulated_tent_keyword\n\t\t\tinsulated_tent_keyword = Game.GetFormFromFile(0x095012, \"Frostfall.esp\") as Keyword\n\t\tendif\n", name + " tent keyword")
save(name, t)
print("Survival Accord hooks applied to 4 scripts")
