"""Draws the VaCSA logo with Pillow (no outside art): docs/logo.png (banner, 1200x400), docs/logo-square.png (512x512 emblem).

    python tools/make_logo.py

The PNGs in docs/ are this drawing run through Upscayl (digital art, 1x) by CageTV; running the script overwrites them with the plain drawing.

Both are drawn at 3x and scaled down so the edges are smooth. The banner is used by the FOMOD (fomod/images) and the Nexus description; the square by the plugin
previews in the installer and as a cover image.
"""
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

root = Path(__file__).resolve().parent.parent
docs = root / "docs"
S = 3  # supersampling

GOLD = (222, 184, 106)
GOLD_DARK = (150, 112, 52)
STEEL = (206, 214, 224)
STEEL_DARK = (122, 132, 148)
NAVY = (18, 26, 40)
NAVY_LIGHT = (34, 48, 70)
FLAME = (236, 120, 50)
FLAME_LIGHT = (255, 205, 110)
FROST = (150, 210, 238)

FONTS = Path(r"C:\Windows\Fonts")


def font(name, size):
    return ImageFont.truetype(str(FONTS / name), int(size * S))


def spaced(draw, xy, text, fnt, fill, spacing):
    """Text with extra letter spacing; xy is the left edge, the baseline-top of the text."""
    x, y = xy
    for ch in text:
        draw.text((x, y), ch, font=fnt, fill=fill)
        x += draw.textlength(ch, font=fnt) + spacing * S
    return x


def spaced_width(draw, text, fnt, spacing):
    return sum(draw.textlength(c, font=fnt) + spacing * S for c in text) - spacing * S


def rot(points, cx, cy, deg):
    a = math.radians(deg)
    return [(cx + (x - cx) * math.cos(a) - (y - cy) * math.sin(a), cy + (x - cx) * math.sin(a) + (y - cy) * math.cos(a)) for x, y in points]


def emblem(img, cx, cy, r):
    """A round shield: gold rim, navy face, crossed sword and axe, a flame, and frost ticks on the rim."""
    d = ImageDraw.Draw(img, "RGBA")
    cx, cy, r = cx * S, cy * S, r * S
    # soft shadow
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).ellipse((cx - r, cy - r + 14 * S, cx + r, cy + r + 14 * S), fill=(0, 0, 0, 150))
    img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(14 * S)))
    d = ImageDraw.Draw(img, "RGBA")
    # rim
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=GOLD_DARK)
    d.ellipse((cx - r + 6 * S, cy - r + 6 * S, cx + r - 6 * S, cy + r - 6 * S), fill=GOLD)
    d.ellipse((cx - r + 20 * S, cy - r + 20 * S, cx + r - 20 * S, cy + r - 20 * S), fill=NAVY)
    d.ellipse((cx - r + 28 * S, cy - r + 28 * S, cx + r - 28 * S, cy + r - 28 * S), fill=NAVY_LIGHT)
    d.ellipse((cx - r + 34 * S, cy - r + 34 * S, cx + r - 34 * S, cy + r - 34 * S), fill=NAVY)
    # knotwork ticks on the rim
    for i in range(24):
        a = math.radians(i * 15)
        x1, y1 = cx + (r - 9 * S) * math.cos(a), cy + (r - 9 * S) * math.sin(a)
        d.ellipse((x1 - 3 * S, y1 - 3 * S, x1 + 3 * S, y1 + 3 * S), fill=GOLD_DARK)

    u = r / 200.0  # design unit: the shield is 400 wide

    def P(pts):
        return [(cx + x * u, cy + y * u) for x, y in pts]

    # sword (blade up) rotated -42 degrees
    blade = [(-9, -150), (0, -168), (9, -150), (9, 40), (-9, 40)]
    guard = [(-38, 40), (38, 40), (38, 54), (-38, 54)]
    grip = [(-6, 54), (6, 54), (6, 100), (-6, 100)]
    for pts, col in ((blade, STEEL), (guard, GOLD), (grip, GOLD_DARK)):
        d.polygon(P(rot(pts, 0, 0, -42)), fill=col)
    d.polygon(P(rot([(-2, -150), (2, -150), (2, 40), (-2, 40)], 0, 0, -42)), fill=STEEL_DARK)
    px, py = rot([(0, 112)], 0, 0, -42)[0]
    d.ellipse((cx + px * u - 11 * u, cy + py * u - 11 * u, cx + px * u + 11 * u, cy + py * u + 11 * u), fill=GOLD)

    # axe (head up) rotated +42 degrees
    haft = [(-6, -120), (6, -120), (6, 112), (-6, 112)]
    head = [(6, -122), (60, -150), (86, -108), (60, -66), (6, -78)]
    beard = [(-6, -122), (-24, -108), (-6, -84)]
    d.polygon(P(rot(haft, 0, 0, 42)), fill=GOLD_DARK)
    d.polygon(P(rot(head, 0, 0, 42)), fill=STEEL)
    d.polygon(P(rot([(14, -112), (62, -135), (78, -108), (62, -80), (14, -88)], 0, 0, 42)), fill=STEEL_DARK)
    d.polygon(P(rot(beard, 0, 0, 42)), fill=STEEL)

    # flame in the middle
    flame = [(0, -70), (28, -22), (36, 18), (18, 52), (0, 60), (-18, 52), (-36, 18), (-26, -20), (-10, -40)]
    d.polygon(P(flame), fill=FLAME)
    d.polygon(P([(0, -34), (16, 4), (20, 30), (0, 52), (-20, 30), (-14, 0)]), fill=FLAME_LIGHT)

    # frost crystal under the flame
    fy = 112
    for k in range(6):
        a = math.radians(k * 60 + 90)
        d.line([(cx, cy + fy * u), (cx + 30 * u * math.cos(a), cy + (fy + 30 * math.sin(a)) * u)], fill=FROST, width=int(4 * u * 1.0) + 1)
        bx, by = cx + 20 * u * math.cos(a), cy + (fy + 20 * math.sin(a)) * u
        for s in (-1, 1):
            b = a + s * math.radians(40)
            d.line([(bx, by), (bx + 10 * u * math.cos(b), by + 10 * u * math.sin(b))], fill=FROST, width=int(3 * u) + 1)


def gradient(w, h, top, bottom):
    img = Image.new("RGBA", (w, h))
    px = img.load()
    for y in range(h):
        t = y / max(1, h - 1)
        c = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)) + (255,)
        for x in range(w):
            px[x, y] = c
    return img


def banner():
    W, H = 1200, 400
    img = gradient(W * S, H * S, (22, 31, 48), (10, 14, 22))
    # faint diagonal strokes (drawn on their own layer so the alpha blends instead of replacing the pixels)
    strokes = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(strokes)
    for i in range(-H, W, 46):
        sd.line([(i * S, H * S), ((i + H) * S, 0)], fill=(255, 255, 255, 9), width=2 * S)
    img.alpha_composite(strokes)
    # glow behind the emblem
    glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((20 * S, 0, 400 * S, 400 * S), fill=(236, 150, 70, 70))
    img.alpha_composite(glow.filter(ImageFilter.GaussianBlur(60 * S)))
    emblem(img, 200, 200, 158)
    d = ImageDraw.Draw(img, "RGBA")
    x0 = 420
    f1 = font("georgiab.ttf", 92)
    f2 = font("georgia.ttf", 30)
    f3 = font("segoeui.ttf", 22)
    spaced(d, (x0 * S, 82 * S), "VALHALLA", f1, GOLD, 8)
    wtitle = spaced_width(d, "VALHALLA", f1, 8) / S
    # divider with diamonds
    ly = 214
    d.line([(x0 * S, ly * S), ((x0 + wtitle) * S, ly * S)], fill=GOLD_DARK, width=2 * S)
    for x in (x0, x0 + wtitle / 2, x0 + wtitle):
        d.polygon([(x * S, (ly - 8) * S), ((x + 8) * S, ly * S), (x * S, (ly + 8) * S), ((x - 8) * S, ly * S)], fill=GOLD)
    sub = "A COMBAT SURVIVAL ACCORD"
    ws = spaced_width(d, sub, f2, 5) / S
    spaced(d, ((x0 + (wtitle - ws) / 2) * S, 240 * S), sub, f2, STEEL, 5)
    tag = "VaCSA   -   Skyrim 1.5.97 to 1.7.104   -   SE and AE"
    wt = spaced_width(d, tag, f3, 1) / S
    spaced(d, ((x0 + (wtitle - wt) / 2) * S, 300 * S), tag, f3, (150, 162, 180), 1)
    return img.convert("RGB").resize((W, H), Image.LANCZOS)


def square():
    W = 512
    img = gradient(W * S, W * S, (22, 31, 48), (10, 14, 22))
    glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((40 * S, 40 * S, 472 * S, 472 * S), fill=(236, 150, 70, 80))
    img.alpha_composite(glow.filter(ImageFilter.GaussianBlur(50 * S)))
    emblem(img, 256, 256, 215)
    return img.convert("RGB").resize((W, W), Image.LANCZOS)


banner().save(docs / "logo.png", optimize=True)
square().save(docs / "logo-square.png", optimize=True)
print("wrote", docs / "logo.png", docs / "logo-square.png")
