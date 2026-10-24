# Valhalla A Combat Survival Accord (VaCSA)

One mod installed in parts (a FOMOD) for Skyrim 1.6.1170 to 1.7.104 (tested on 1.7.104); untested legacy builds of Survival Accord and Valhalla Combat cover SE 1.5.97 and AE before 1.6.1170:

| Part | What it is | Source |
|---|---|---|
| Survival Accord | Firmament perks for Last Seed 2026 and Frostfall 2026 (this repository) | here |
| Valhalla Combat 1.7 build | Valhalla Combat with Stop On Slash, Elden Counter and Elden Parry built in | [valhallaCombat](https://github.com/CageTV/valhallaCombat), branch `ng-17x` |
| Archery Locational Damage 1.7 build | the DLL for 1.7.104 | [ArcheryLocationalDamage](https://github.com/CageTV/ArcheryLocationalDamage), branch `ng-17x` |
| DPF RE 1.7.104 DLL | DPF RE for 1.7.104, needed by Parry for All | [DPF](https://github.com/CageTV/DPF), branch `ng-17x` |

The installer lists the mods each part needs; the Nexus description is in [docs/NEXUS_DESCRIPTION.bbcode](docs/NEXUS_DESCRIPTION.bbcode). Licenses and notices of every part are in
`licenses/` and are installed to `Data/Licenses`. `python tools/package_release.py` builds `release/VaCSA-<version>.zip` from the four builds.

## Survival Accord

Connects **Firmament**'s Exploration perks to **Last Seed 2026** (Hunger, Fatigue, camping) and **Frostfall 2026** (cold Exposure), and is the
place where more survival integrations will land. It is built for the 2026 versions of Last Seed and Frostfall (our updated builds of the originals),
so everything in the list fits together. No ESP or ESL is added.

> **Pre-release: compiled, but not tested in game yet.**

## What it does

| Firmament | Effect |
|---|---|
| Resilience I-V | Frostfall cold Exposure gains 10 / 20 / 30 / 40 / 50% slower |
| Fortify Exploration (equipment) | The same, by the summed magnitude of the active effects. Added to Resilience, capped at 100% |
| Camper I-II | Last Seed Fatigue 20 / 40% slower; sleeping outdoors counts as a Well Rested sleep |
| Field Rations I-II | Food restores 1.5x / 2.0x Last Seed Hunger (Hunger only, never Thirst) |
| Dungeon Delver | Hunger and Fatigue 50% slower inside a Last Seed dungeon interior |
| Pathfinder (ExplorationPotions) | Hunger and Fatigue slower by the ExplorationPotions value (15% -> x0.85 ... 60% -> x0.40) |

Multipliers stack by multiplication. Without Firmament every multiplier is 1.0, so the scripts behave exactly like Last Seed 2026 and Frostfall 2026.

Compared with the older "Firmament - Last Seed & Frostfall Compatibility" patch:

- the scripts are built on **Last Seed 2026** and **Frostfall 2026** (their fixes are kept, such as the Campfire tent sleep fix), instead of replacing them with the original scripts;
- the delayed (menu / focus) Hunger and Fatigue cycles apply the Firmament multipliers too;
- the perks are checked by the DLL (no `GetFormFromFile` call in every update), and it does nothing when Firmament is missing;
- nothing in `Firmament.dll` is patched in memory. See "Known limits".

## Install

Needs SKSE, Address Library, Last Seed 2026 and/or Frostfall 2026, and Firmament (without Firmament it does nothing). Install with MO2 after Last Seed 2026
and Frostfall 2026 (below them in the left pane) so its scripts win the conflicts. The installer pre-selects the parts that match your load order.

Do not install it together with "Firmament - Last Seed & Frostfall Compatibility" or "FirmamentFrostfallCompat": they replace the same scripts. The DLL logs an
error in `SurvivalAccord.log` if it finds either of them.

## Known limits

- **Camper and Firmament's own sleep handler.** Firmament 1.0 has its own Well Rested handler for the Bethesda Survival Mode. The old patch turns that handler
  off in memory; Survival Accord does not (it would mean patching another mod's code). If you run Bethesda's Survival Mode you might get the bonus twice.
  Last Seed replaces Survival Mode, so most setups are not affected.
- The scripts are replacements of four Last Seed 2026 / Frostfall 2026 scripts. If either mod changes one of those scripts, Survival Accord has to follow.
- Skyrim VR is not covered. Versions before 1.6.1170 only have the untested legacy builds of Survival Accord and Valhalla Combat; the other two DLLs have none.

## Hunterborn

Hunterborn support is **coming soon**. `SurvivalAccord.dll` already looks for `Hunterborn.esp` and logs it; `SurvivalAccordNative.GetHunterbornStatus()` returns `coming soon`.

## Building

`python tools/build_scripts.py` compiles `src/scripts` (see the paths at the top of the file), then build `plugin/` with the shared ng build
(`E:\WorkSpace\ng-build`, target `SurvivalAccord`), and `python tools/package_release.py` writes the FOMOD zip. `tools/apply_hooks.py` documents exactly which
lines were added to the Last Seed and Frostfall scripts.

## Credits and licences

- **Chesko and Aytrus** - Last Seed; **Chesko** - Frostfall and Campfire. The four scripts here are modified versions of theirs, used under their MIT licence.
- **JPSteel2** - Firmament. **Parapets** - Constellations. Survival Accord does not contain their files.
- The design follows the "Firmament - Last Seed & Frostfall Compatibility" patch (Nexus 188360), which showed which Firmament effects map to which survival need.
- This work is released under the MIT License ([LICENSE.txt](LICENSE.txt)). `SurvivalAccord.dll` is built with alandtse's CommonLibSSE-NG and is therefore a
  combined work under the GPL-3.0-or-later ([NOTICE.txt](NOTICE.txt), [LICENSE-GPL-3.0.txt](LICENSE-GPL-3.0.txt)).
