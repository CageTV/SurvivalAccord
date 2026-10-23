"""Packages the Survival Accord release zip (a FOMOD installer).

Run after `python tools/build_scripts.py` and the DLL build (E:/WorkSpace/ng-build, target SurvivalAccord):

    python tools/package_release.py        ->  release/SurvivalAccord-<version>.zip

Zip layout (the folder names are the ones fomod/ModuleConfig.xml installs from):
    fomod/info.xml, fomod/ModuleConfig.xml
    LICENSE.txt, NOTICE.txt, LICENSE-GPL-3.0.txt
    Core/SKSE/Plugins/SurvivalAccord.dll, Core/Scripts/SA_Firmament.pex, Core/Scripts/SurvivalAccordNative.pex (+ Source)
    Last Seed/Scripts/_Seed_FatigueSystem.pex, _Seed_HungerSystem.pex, _Seed_PlayerEatMonitor.pex (+ Source)
    Frostfall/Scripts/_Frost_ExposureSystem.pex (+ Source)
"""
import re
import sys
import xml.dom.minidom
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parent.parent
version = re.search(r"<Version>([0-9.]+)</Version>", (root / "fomod/info.xml").read_text(encoding="utf-8")).group(1)
dll = Path(r"E:\WorkSpace\ng-build\build\release\out\SurvivalAccord\SurvivalAccord.dll")
scripts = root / "release-contents" / "Scripts"

GROUPS = {
    "Core": ["SA_Firmament", "SurvivalAccordNative"],
    "Last Seed": ["_Seed_FatigueSystem", "_Seed_HungerSystem", "_Seed_PlayerEatMonitor"],
    "Frostfall": ["_Frost_ExposureSystem"],
}
TOP = ["LICENSE.txt", "NOTICE.txt", "LICENSE-GPL-3.0.txt"]

if not dll.is_file():
    sys.exit(f"missing {dll} - build the DLL first")
if f"{version}".encode() not in dll.read_bytes():
    sys.exit(f"{dll} was not built from version {version}")
for name in sum(GROUPS.values(), []):
    if not (scripts / f"{name}.pex").is_file() or not (scripts / "Source" / f"{name}.psc").is_file():
        sys.exit(f"missing {name}.pex / .psc - run tools/build_scripts.py")
for xml_file in ("fomod/info.xml", "fomod/ModuleConfig.xml"):
    xml.dom.minidom.parse(str(root / xml_file))  # well-formed

config = (root / "fomod/ModuleConfig.xml").read_text(encoding="utf-8")
sources = set(re.findall(r'source="([^"]+)"', config))
expected = {*GROUPS, *TOP}
if sources != expected:
    sys.exit(f"ModuleConfig.xml installs from {sorted(sources)} but the zip holds {sorted(expected)}")

out = root / "release" / f"SurvivalAccord-{version}.zip"
out.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    z.write(root / "fomod/info.xml", "fomod/info.xml")
    z.write(root / "fomod/ModuleConfig.xml", "fomod/ModuleConfig.xml")
    for t in TOP:
        z.write(root / t, t)
    z.write(dll, "Core/SKSE/Plugins/SurvivalAccord.dll")
    for folder, names in GROUPS.items():
        for n in names:
            z.write(scripts / f"{n}.pex", f"{folder}/Scripts/{n}.pex")
            z.write(scripts / "Source" / f"{n}.psc", f"{folder}/Scripts/Source/{n}.psc")
with zipfile.ZipFile(out) as z:
    assert z.testzip() is None
    for i in z.infolist():
        print(f"{i.file_size:>9}  {i.filename}")
print("wrote", out)
