#!/usr/bin/env python3
"""Renders screenshots/banner.png from the app screenshots.

Usage: python3 tool/generate_banner.py <empty-state-screenshot.png>
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SHOTS = ROOT / 'screenshots'
W, H = 1600, 800


def font(size, weight='Bold', path='/System/Library/Fonts/SFNS.ttf'):
    f = ImageFont.truetype(path, size)
    try:
        f.set_variation_by_name(weight)
    except Exception:
        pass
    return f


def background():
    bg = Image.new('RGB', (W, H))
    px = bg.load()
    a, b, c = (14, 16, 48), (49, 46, 129), (8, 112, 140)
    for y in range(H):
        for x in range(W):
            t = x / W * 0.75 + y / H * 0.25
            if t < 0.55:
                k = t / 0.55
                px[x, y] = tuple(int(a[i] + (b[i] - a[i]) * k) for i in range(3))
            else:
                k = (t - 0.55) / 0.45
                px[x, y] = tuple(int(b[i] + (c[i] - b[i]) * k) for i in range(3))
    glow = Image.new('RGB', (W, H))
    g = ImageDraw.Draw(glow)
    g.ellipse((950, -250, 1550, 350), fill=(99, 102, 241))
    g.ellipse((1150, 450, 1750, 1050), fill=(6, 182, 212))
    g.ellipse((-250, 450, 350, 1050), fill=(79, 70, 229))
    return Image.blend(bg, glow.filter(ImageFilter.GaussianBlur(170)), 0.4)


def phone(path, w):
    im = Image.open(path).convert('RGB')
    h = int(im.height * w / im.width)
    im = im.resize((w, h), Image.LANCZOS)
    b = 12
    frame = Image.new('RGBA', (w + 2 * b, h + 2 * b), (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle(
        (0, 0, w + 2 * b - 1, h + 2 * b - 1), radius=int(w * 0.16),
        fill=(18, 18, 24, 255), outline=(90, 90, 110, 255), width=3)
    mask = Image.new('L', (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w - 1, h - 1), radius=int(w * 0.13), fill=255)
    frame.paste(im, (b, b), mask)
    return frame


def shadow(img):
    s = Image.new('RGBA', (img.width + 120, img.height + 120), (0, 0, 0, 0))
    s.paste((0, 0, 0, 255), (60, 80), img.split()[3].point(lambda v: 150 if v else 0))
    return s.filter(ImageFilter.GaussianBlur(30))


def main():
    empty = sys.argv[1]
    canvas = background().convert('RGBA')
    for path, cx, y, rot in [
        (SHOTS / 'overlay.png', 985, 170, -6),
        (empty, 1435, 170, 6),
        (SHOTS / 'states.png', 1210, 95, 0),
    ]:
        p, sh = phone(path, 250), None
        sh = shadow(p)
        if rot:
            p = p.rotate(rot, resample=Image.BICUBIC, expand=True)
            sh = sh.rotate(rot, resample=Image.BICUBIC, expand=True)
        canvas.alpha_composite(sh, (cx - sh.width // 2, y - 40))
        canvas.alpha_composite(p, (cx - p.width // 2, y))

    d = ImageDraw.Draw(canvas)
    d.text((90, 215), 'base_widget_flutter', font=font(70), fill=(255, 255, 255))
    d.text((94, 320), 'One base widget for every Flutter screen', font=font(38, 'Semibold'), fill=(226, 228, 250))
    d.text((94, 375), 'Loading overlay · States · Pull-to-refresh · Styles', font=font(29, 'Regular'), fill=(186, 190, 225))

    labels = ['Blur overlay', 'BaseStateView', 'API & prefs', '6 platforms']
    f = font(24, 'Semibold')
    overlay = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    x = 94
    for label in labels:
        w = d.textlength(label, font=f)
        od.rounded_rectangle((x, 465, x + w + 40, 513), radius=24, fill=(255, 255, 255, 36),
                             outline=(255, 255, 255, 110), width=2)
        x += w + 56
    canvas.alpha_composite(overlay)
    d = ImageDraw.Draw(canvas)
    x = 94
    for label in labels:
        w = d.textlength(label, font=f)
        d.text((x + 20, 473), label, font=f, fill=(255, 255, 255))
        x += w + 56
    d.text((94, 590), 'flutter pub add base_widget_flutter', font=font(26, 'Regular', '/System/Library/Fonts/SFNSMono.ttf'),
           fill=(150, 220, 255))
    canvas.convert('RGB').save(SHOTS / 'banner.png', optimize=True)


if __name__ == '__main__':
    main()
