"""Packages the Valhalla A Combat Survival Accord release zip (a FOMOD installer).

Run after `python tools/build_scripts.py` and the DLL builds (E:/WorkSpace/ng-build: targets SurvivalAccord, ValhallaCombat, ArcheryLocationalDamage, DPF), and after
the light plugin was built in E:/WorkSpace/valhallaCombat (tools/esl_build.py):

    python tools/package_release.py        ->  release/VaCSA-<version>.zip

Zip layout (the folder names are the ones fomod/ModuleConfig.xml installs from):
    fomod/info.xml, fomod/ModuleConfig.xml
    LICENSE.txt, NOTICE.txt, LICENSE-GPL-3.0.txt
    Core/Scripts/SA_Firmament.pex, Core/Scripts/SurvivalAccordNative.pex (+ Source)
    Current/<part>/SKSE/Plugins/*.dll (SurvivalAccord, ValhallaCombat, ArcheryLocationalDamage, DPF), Legacy/<part>/... (SurvivalAccord, ValhallaCombat)
    Last Seed/Scripts/*.pex (+ Source), Frostfall/Scripts/_Frost_ExposureSystem.pex (+ Source)
    Valhalla Combat/ValhallaCombat.esp, SKSE/Plugins/ValhallaCombat/Killmoves.ini, RaceMapping/Vanilla.ini, Licenses/*
    Archery Locational Damage/Licenses/*, DPF/Licenses/*
"""
import re
import sys
import xml.dom.minidom
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parent.parent
work = root.parent
version = re.search(r"<Version>([0-9.]+)</Version>", (root / "fomod/info.xml").read_text(encoding="utf-8")).group(1)
out_dir = Path(r"E:\WorkSpace\ng-build\build\release\out")
plugin_version = re.search(r"VERSION ([0-9.]+)", (root / "plugin/ng.cmake").read_text(encoding="utf-8")).group(1)
scripts = root / "release-contents" / "Scripts"
vc = work / "valhallaCombat"

GROUPS = {
    "Core": ["SA_Firmament", "SurvivalAccordNative"],
    "Last Seed": ["_Seed_FatigueSystem", "_Seed_HungerSystem", "_Seed_PlayerEatMonitor"],
    "Frostfall": ["_Frost_ExposureSystem"],
}
TOP = ["LICENSE.txt", "NOTICE.txt", "LICENSE-GPL-3.0.txt", "ThirdParty-Notices.txt"]
LIC = root / "licenses"

# folder in the zip -> list of (source file, path inside the folder). The DLLs are in their own folders (Current/ and Legacy/) that the installer picks by the
# Skyrim version page: current = alandtse's CommonLibSSE-NG build (1.6.1170 and newer), legacy = CharmedBaryon's build (SE 1.5.97, AE before 1.6.1170, untested).
LEGACY_VC = vc / "legacy" / "build" / "release" / "ValhallaCombat.dll"
LEGACY_SA = root / "plugin" / "build" / "release" / "SurvivalAccord.dll"
COMBAT = {
    "Valhalla Combat": [
        (vc / "release-contents" / "ValhallaCombat.esp", "ValhallaCombat.esp"),
        (vc / "data" / "SKSE/Plugins/ValhallaCombat/Killmoves.ini", "SKSE/Plugins/ValhallaCombat/Killmoves.ini"),
        (vc / "data" / "SKSE/Plugins/ValhallaCombat/RaceMapping/Vanilla.ini", "SKSE/Plugins/ValhallaCombat/RaceMapping/Vanilla.ini"),
        (LIC / "ValhallaCombat-BSD-3-Clause.txt", "Licenses/ValhallaCombat-BSD-3-Clause.txt"),
        (LIC / "ValhallaCombat-NOTICE.txt", "Licenses/ValhallaCombat-NOTICE.txt"),
    ],
    "Archery Locational Damage": [
        (LIC / "ArcheryLocationalDamage-MIT.txt", "Licenses/ArcheryLocationalDamage-MIT.txt"),
        (LIC / "ArcheryLocationalDamage-NOTICE.txt", "Licenses/ArcheryLocationalDamage-NOTICE.txt"),
    ],
    "DPF": [
        (LIC / "DPF-NOTICE.txt", "Licenses/DPF-NOTICE.txt"),
    ],
    "Current/SurvivalAccord": [(out_dir / "SurvivalAccord" / "SurvivalAccord.dll", "SKSE/Plugins/SurvivalAccord.dll")],
    "Legacy/SurvivalAccord": [(LEGACY_SA, "SKSE/Plugins/SurvivalAccord.dll")],
    "Current/ValhallaCombat": [(out_dir / "ValhallaCombat" / "ValhallaCombat.dll", "SKSE/Plugins/ValhallaCombat.dll")],
    "Legacy/ValhallaCombat": [(LEGACY_VC, "SKSE/Plugins/ValhallaCombat.dll")],
    "Current/ArcheryLocationalDamage": [(out_dir / "ArcheryLocationalDamage" / "ArcheryLocationalDamage.dll", "SKSE/Plugins/ArcheryLocationalDamage.dll")],
    "Current/DPF": [(out_dir / "DPF" / "DPF.dll", "SKSE/Plugins/DPF.dll")],
}
dll = out_dir / "SurvivalAccord" / "SurvivalAccord.dll"

if not dll.is_file():
    sys.exit(f"missing {dll} - build the DLL first")
for d in (dll, LEGACY_SA):
    if not d.is_file() or plugin_version.encode() not in d.read_bytes():
        sys.exit(f"{d} is missing or was not built from version {plugin_version}")
for name in sum(GROUPS.values(), []):
    if not (scripts / f"{name}.pex").is_file() or not (scripts / "Source" / f"{name}.psc").is_file():
        sys.exit(f"missing {name}.pex / .psc - run tools/build_scripts.py")
for folder, files in COMBAT.items():
    for src, _ in files:
        if not Path(src).is_file():
            sys.exit(f"missing {src} ({folder})")
for xml_file in ("fomod/info.xml", "fomod/ModuleConfig.xml"):
    xml.dom.minidom.parse(str(root / xml_file))  # well-formed

config = (root / "fomod/ModuleConfig.xml").read_text(encoding="utf-8")
sources = set(re.findall(r'source="([^"]+)"', config))
expected = {*GROUPS, *COMBAT, *TOP}
if sources != expected:
    sys.exit(f"ModuleConfig.xml installs from {sorted(sources)} but the zip holds {sorted(expected)}")

out = root / "release" / f"VaCSA-{version}.zip"
out.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    z.write(root / "fomod/info.xml", "fomod/info.xml")
    z.write(root / "fomod/ModuleConfig.xml", "fomod/ModuleConfig.xml")
    z.write(root / "docs/logo.png", "fomod/images/logo.png")
    z.write(root / "docs/logo-square.png", "fomod/images/logo-square.png")
    for t in TOP:
        z.write(root / ("licenses/" + t if t.startswith("ThirdParty") else t), t)
    for folder, names in GROUPS.items():
        for n in names:
            z.write(scripts / f"{n}.pex", f"{folder}/Scripts/{n}.pex")
            z.write(scripts / "Source" / f"{n}.psc", f"{folder}/Scripts/Source/{n}.psc")
    for folder, files in COMBAT.items():
        for src, inside in files:
            z.write(src, f"{folder}/{inside}")
        if not folder.startswith(("Current/", "Legacy/")):
            z.write(root / "LICENSE-GPL-3.0.txt", f"{folder}/Licenses/LICENSE-GPL-3.0.txt")
with zipfile.ZipFile(out) as z:
    assert z.testzip() is None
    assert not any("\\" in n for n in z.namelist())
    for i in z.infolist():
        print(f"{i.file_size:>9}  {i.filename}")
print("wrote", out)
