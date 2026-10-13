#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Resk 鸿蒙应用图标 —— 构建脚本

输入:  每个方案目录下的 background.svg / foreground.svg (1024x1024 画布, 矢量母版)
输出:  图层 PNG (1024, 透明) / 合成 icon-1024.png / icon.svg / 各尺寸 PNG / 预览图 / 交付资源

用法:  python build.py [--only 方案A-品牌蓝R]
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.abspath(__file__))
DESIGN = os.path.dirname(ROOT)  # design/app-icon
EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
FONT = r"C:\Windows\Fonts\msyh.ttc"

LIGHT_BG = "#EDF3FA"
DARK_BG = "#10181F"
LIGHT_CARD = "#FFFFFF"
DARK_CARD = "#17222D"
TEXT_DARK = "#122B42"
TEXT_LIGHT = "#E9F1F8"
MUTED_DARK = "#6D8499"
MUTED_LIGHT = "#8FA7BA"

CONCEPTS = [
    ("方案A-品牌蓝R", "A · 品牌蓝 R + 在线光点", "延续 R 字识别，天空蓝渐变，最小尺寸最稳"),
    ("方案B-暗夜光感R", "B · 暗夜光感 R", "深色底 + 发光字形，贴合深色/沉浸光感"),
    ("方案C-屏幕互联", "C · 屏幕互联", "显示器 + 光标 + 联机点，功能直述"),
]
RECOMMENDED = "方案A-品牌蓝R"
EXPORT_SIZES = [1024, 512, 216, 144, 96, 72, 48]


# ---------------------------------------------------------------- 渲染
def render_svg(svg_path, out_png, size=1024):
    svg = open(svg_path, "r", encoding="utf-8").read()
    html = (
        "<!doctype html><html><head><meta charset=\"utf-8\"><style>"
        "html,body{margin:0;padding:0;background:transparent;overflow:hidden}"
        "svg{display:block}</style></head><body>" + svg + "</body></html>"
    )
    tmpdir = tempfile.mkdtemp(prefix="icon-render-")
    html_path = os.path.join(tmpdir, "a.html")
    open(html_path, "w", encoding="utf-8").write(html)
    profile = os.path.join(tmpdir, "profile")
    uri = "file:///" + html_path.replace("\\", "/")
    if os.path.exists(out_png):
        os.remove(out_png)
    cmd = [
        EDGE, "--headless=new", "--disable-gpu", "--no-first-run",
        "--no-default-browser-check", "--hide-scrollbars",
        "--force-device-scale-factor=1", f"--user-data-dir={profile}",
        "--default-background-color=00000000", f"--window-size={size},{size}",
        f"--screenshot={out_png}", uri,
    ]
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    shutil.rmtree(tmpdir, ignore_errors=True)
    if not os.path.exists(out_png):
        raise RuntimeError("渲染失败: " + svg_path)
    im = Image.open(out_png)
    if im.size != (size, size):
        raise RuntimeError(f"渲染尺寸异常 {im.size} != {(size, size)}")
    return im.convert("RGBA")


def merge_svg(bg_path, fg_path):
    def inner(p):
        s = open(p, "r", encoding="utf-8").read()
        return s[s.index(">", s.index("<svg")) + 1: s.rindex("</svg>")].strip()

    return (
        '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">\n'
        '  <g id="background-layer">\n' + inner(bg_path) + "\n  </g>\n"
        '  <g id="foreground-layer">\n' + inner(fg_path) + "\n  </g>\n"
        "</svg>\n"
    )


def build_start_icon(bg_path, fg_path):
    """启动页图标 (startWindowIcon): 同一设计 + 系统同款圆角, 144pt 视图."""
    def defs_of(p):
        s = open(p, "r", encoding="utf-8").read()
        return re.search(r"<defs>(.*?)</defs>", s, re.S).group(1)

    def body_of(p):
        s = open(p, "r", encoding="utf-8").read()
        body = s[s.index(">", s.index("<svg")) + 1: s.rindex("</svg>")]
        return re.sub(r"<defs>.*?</defs>", "", body, flags=re.S).strip()

    return (
        '<svg xmlns="http://www.w3.org/2000/svg" width="144" height="144" viewBox="0 0 1024 1024">\n'
        "  <defs>\n" + defs_of(bg_path) + "\n" + defs_of(fg_path) + "\n"
        '    <clipPath id="startClip"><rect x="0" y="0" width="1024" height="1024" rx="232" ry="232"/></clipPath>\n'
        "  </defs>\n"
        '  <g clip-path="url(#startClip)">\n' + body_of(bg_path) + "\n  </g>\n"
        '  <g clip-path="url(#startClip)">\n' + body_of(fg_path) + "\n  </g>\n"
        "</svg>\n"
    )


# ---------------------------------------------------------------- 绘图工具
def font(size):
    try:
        return ImageFont.truetype(FONT, size)
    except Exception:
        return ImageFont.load_default()


def rounded_mask(size, factor=0.235):
    m = Image.new("L", (size, size), 0)
    ImageDraw.Draw(m).rounded_rectangle(
        [0, 0, size - 1, size - 1], radius=int(round(size * factor)), fill=255
    )
    return m


def masked_icon(icon, size):
    im = icon.resize((size, size), Image.LANCZOS)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(im, (0, 0), rounded_mask(size))
    return out


def checker(size, cell=10):
    im = Image.new("RGBA", (size, size), (255, 255, 255, 255))
    d = ImageDraw.Draw(im)
    for y in range(0, size, cell):
        for x in range(0, size, cell):
            if (x // cell + y // cell) % 2:
                d.rectangle([x, y, x + cell - 1, y + cell - 1], fill=(222, 228, 235, 255))
    return im


def paste_center(canvas, im, cx, cy):
    canvas.alpha_composite(im, (int(cx - im.width / 2), int(cy - im.height / 2)))


def text_center(canvas, txt, cx, cy, size, color, bold=False):
    d = ImageDraw.Draw(canvas)
    f = font(size)
    box = d.textbbox((0, 0), txt, font=f)
    d.text((cx - (box[2] - box[0]) / 2 - box[0], cy - (box[3] - box[1]) / 2 - box[1]),
           txt, font=f, fill=color)


def strip(canvas, icons, sizes, x, y, gap, label_color, label=None):
    """一行小尺寸图标, 底部对齐, 返回宽度"""
    cx = x
    for size in sizes:
        paste_center(canvas, icons[size], cx + size / 2, y + max(sizes) / 2)
        cx += size + gap
    if label:
        text_center(canvas, label, x + (cx - gap - x) / 2, y + max(sizes) + 26, 20, label_color)
    return cx - gap - x


# ---------------------------------------------------------------- 预览图
def preview_compare(results):
    pad, card_w, icon = 56, 300, 232
    W = pad * 2 + card_w * 3 + 40 * 2
    H = pad + 64 + 300 + 80 + 300 + 90 + 260 + pad
    im = Image.new("RGBA", (W, H), (247, 250, 253, 255))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, W, 64 + pad + 300 + 40], fill=(247, 250, 253, 255))
    d.rectangle([0, 64 + pad + 300 + 40, W, 64 + pad + 300 + 40 + 300 + 90], fill=(16, 24, 31, 255))

    text_center(im, "Resk · 鸿蒙应用图标 方案对比", W // 2, pad + 22, 34, TEXT_DARK)

    # 亮色桌面
    y0 = pad + 64
    text_center(im, "亮色桌面 #EDF3FA", W // 2, y0 - 26, 22, MUTED_DARK)
    for i, (folder, title, note) in enumerate(CONCEPTS):
        cx = pad + i * (card_w + 40)
        card = Image.new("RGBA", (card_w, 300), (255, 255, 255, 255))
        ImageDraw.Draw(card).rounded_rectangle([0, 0, card_w - 1, 299], radius=28,
                                               outline=(214, 226, 238, 255), width=2)
        paste_center(card, masked_icon(results[folder]["icon"], icon), card_w / 2, 130)
        text_center(card, title, card_w / 2, 236, 22, TEXT_DARK)
        text_center(card, note, card_w / 2, 266, 17, MUTED_DARK)
        im.alpha_composite(card, (cx, y0))

    # 深色桌面
    y1 = y0 + 300 + 90
    text_center(im, "深色桌面 #10181F", W // 2, y1 - 26, 22, MUTED_LIGHT)
    for i, (folder, title, note) in enumerate(CONCEPTS):
        cx = pad + i * (card_w + 40)
        card = Image.new("RGBA", (card_w, 300), (23, 34, 45, 255))
        ImageDraw.Draw(card).rounded_rectangle([0, 0, card_w - 1, 299], radius=28,
                                               outline=(46, 62, 78, 255), width=2)
        paste_center(card, masked_icon(results[folder]["icon"], icon), card_w / 2, 130)
        text_center(card, title, card_w / 2, 236, 22, TEXT_LIGHT)
        text_center(card, note, card_w / 2, 266, 17, MUTED_LIGHT)
        im.alpha_composite(card, (cx, y1))

    # 小尺寸
    y2 = y1 + 300 + 70
    text_center(im, "小尺寸检验（96 / 72 / 48 / 36 px）", W // 2, y2 - 30, 22, MUTED_DARK)
    for i, (folder, title, note) in enumerate(CONCEPTS):
        cx = pad + i * (card_w + 40)
        card = Image.new("RGBA", (card_w, 200), (255, 255, 255, 255))
        ImageDraw.Draw(card).rounded_rectangle([0, 0, card_w - 1, 199], radius=24,
                                               outline=(214, 226, 238, 255), width=2)
        dd = ImageDraw.Draw(card)
        for j, size in enumerate([96, 72, 48, 36]):
            paste_center(card, masked_icon(results[folder]["icon"], size), 56 + j * 63, 88)
        dd.line([24, 150, card_w - 24, 150], fill=(230, 238, 246, 255), width=2)
        card.paste(Image.new("RGBA", (card_w, 50), (16, 24, 31, 255)),
                   (0, 150), Image.new("L", (card_w, 50), 0))
        strip_card = card.copy()
        dd2 = ImageDraw.Draw(strip_card)
        dd2.rounded_rectangle([1, 151, card_w - 2, 198], radius=0, fill=(16, 24, 31, 255))
        for j, size in enumerate([96, 72, 48, 36]):
            paste_center(strip_card, masked_icon(results[folder]["icon"], size), 56 + j * 63, 174)
        im.alpha_composite(strip_card, (cx, y2))
    return im


def preview_single(folder, title, res, note):
    icon = res["icon"]
    W, H = 1080, 1010
    im = Image.new("RGBA", (W, H), (247, 250, 253, 255))
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, W, 300], fill=(255, 255, 255, 255))
    d.rectangle([0, 300, W, 560], fill=(16, 24, 31, 255))
    d.rectangle([0, 560, W, H], fill=(247, 250, 253, 255))
    text_center(im, "Resk 鸿蒙应用图标 · " + title, W // 2, 34, 30, TEXT_DARK)
    text_center(im, note, W // 2, 68, 19, MUTED_DARK)
    paste_center(im, masked_icon(icon, 200), 180, 300 - 90)
    for i, size in enumerate([216, 144, 96, 72, 48]):
        paste_center(im, masked_icon(icon, size), 360 + i * 150, 300 - 90)
    paste_center(im, masked_icon(icon, 200), 180, 430)
    for i, size in enumerate([216, 144, 96, 72, 48]):
        paste_center(im, masked_icon(icon, size), 360 + i * 150, 430)

    # 图层拆解
    text_center(im, "图层拆解（鸿蒙分层图标：前景 + 背景，系统统一加圆角）", W // 2, 610, 24, TEXT_DARK)
    labels = [("背景层 background.png", res["bg"]),
              ("前景层 foreground.png", res["fg"]),
              ("合成效果（系统圆角）", icon)]
    for i, (lab, img) in enumerate(labels):
        cx = 180 + i * 360
        card = checker(300)
        ImageDraw.Draw(card).rounded_rectangle([0, 0, 299, 299], radius=24,
                                              outline=(206, 218, 230, 255), width=2)
        inner = masked_icon(img, 236) if i == 2 else img.resize((236, 236), Image.LANCZOS)
        paste_center(card, inner, 150, 150)
        im.alpha_composite(card, (cx - 150, 660))
        text_center(im, lab, cx, 990, 20, MUTED_DARK)
    return im


# ---------------------------------------------------------------- 主流程
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default=None)
    args = ap.parse_args()

    results = {}
    for folder, title, note in CONCEPTS:
        if args.only and folder != args.only:
            continue
        cdir = os.path.join(DESIGN, folder)
        if not os.path.isdir(cdir):
            continue
        bg_svg = os.path.join(cdir, "background.svg")
        fg_svg = os.path.join(cdir, "foreground.svg")
        print("== " + folder)
        bg = render_svg(bg_svg, os.path.join(cdir, "background.png"))
        fg = render_svg(fg_svg, os.path.join(cdir, "foreground.png"))
        icon = bg.copy()
        icon.alpha_composite(fg)
        icon.save(os.path.join(cdir, "icon-1024.png"))
        for size in EXPORT_SIZES:
            icon.resize((size, size), Image.LANCZOS).save(os.path.join(cdir, f"icon-{size}.png"))
        open(os.path.join(cdir, "icon.svg"), "w", encoding="utf-8").write(merge_svg(bg_svg, fg_svg))
        results[folder] = {"icon": icon, "bg": bg, "fg": fg, "title": title, "note": note,
                           "dir": cdir, "bg_svg": bg_svg, "fg_svg": fg_svg}
        print(f"   -> icon-1024.png / icon.svg / {len(EXPORT_SIZES)} 个尺寸")

    if len(results) == len(CONCEPTS):
        preview_compare(results).convert("RGB").save(os.path.join(DESIGN, "预览-方案对比.png"))
        print("== 预览-方案对比.png")
    if RECOMMENDED in results:
        r = results[RECOMMENDED]
        preview_single(RECOMMENDED, r["title"], r, r["note"]).convert("RGB").save(
            os.path.join(DESIGN, "预览-推荐方案.png"))
        print("== 预览-推荐方案.png")

        # 交付资源 (可直接拷入工程)
        out = os.path.join(DESIGN, "交付-方案A")
        os.makedirs(out, exist_ok=True)
        r["bg"].save(os.path.join(out, "resk_background.png"))
        r["fg"].save(os.path.join(out, "resk_foreground.png"))
        r["icon"].save(os.path.join(out, "resk.png"))
        r["icon"].resize((216, 216), Image.LANCZOS).save(os.path.join(out, "resk-market-216.png"))
        open(os.path.join(out, "layered_image.json"), "w", encoding="utf-8").write(
            json.dumps({"layered-image": {"background": "$media:resk_background",
                                          "foreground": "$media:resk_foreground"}},
                       ensure_ascii=False, indent=2) + "\n")
        start_svg = os.path.join(out, "startIcon.svg")
        open(start_svg, "w", encoding="utf-8").write(build_start_icon(r["bg_svg"], r["fg_svg"]))
        render_svg(start_svg, os.path.join(out, "startIcon-144.png"), 144)
        print("== 交付-方案A/ (分层图标资源 + 启动图标)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
