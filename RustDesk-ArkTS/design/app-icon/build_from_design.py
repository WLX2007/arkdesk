#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""ArkDesk 应用图标 —— 由设计稿生成鸿蒙分层图标资源。

输入 (design/app-icon/):
    background.png  设计稿背景层
    foreground.png  设计稿前景层（透明底）
    background.svg / foreground.svg  矢量母版（CorelDRAW 导出，仅作存档参考）

输出 (ARKDESK_OUT，默认本目录):
    arkdesk_background.png   1024×1024 不透明  分层图标背景层
    arkdesk_foreground.png   1024×1024 透明底  分层图标前景层
    arkdesk.png              1024×1024         兜底/直角图标
    arkdesk-market-216.png   216×216           AGC 上架用
    startIcon-144.png        144×144 圆角      启动图标预览
    startIcon.svg            144×144 视图     启动页 startWindowIcon
    layered_image.json       分层图标声明

用法: python build_from_design.py
"""
import json
import os
import sys

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.environ.get("ARKDESK_OUT", ROOT)

TARGET = 1024
EXPORT_SIZES = [1024, 512, 216, 144, 96, 72, 48, 36]

# 设计稿前景层四周留白比例：CorelDRAW 画布 256mm 中主体居中，
# 直接铺满 1024 会让主体偏大，这里保持与设计稿一致的安全区比例。
FG_SCALE = 0.86


def load_layer(name, size, scale=1.0, center=True):
    """读取设计稿图层并归一化到目标尺寸。"""
    path = os.path.join(ROOT, name)
    if not os.path.exists(path):
        raise RuntimeError("缺少设计稿图层: " + path)
    im = Image.open(path).convert("RGBA")
    if scale != 1.0:
        inner = max(1, int(round(size * scale)))
        im = im.resize((inner, inner), Image.LANCZOS)
        if center:
            canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
            off = (size - inner) // 2
            canvas.alpha_composite(im, (off, off))
            im = canvas
    elif im.size != (size, size):
        im = im.resize((size, size), Image.LANCZOS)
    return im


def rounded(im, radius):
    out = Image.new("RGBA", im.size, (0, 0, 0, 0))
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, im.size[0] - 1, im.size[1] - 1], radius=radius, fill=255
    )
    out.paste(im, (0, 0), mask)
    return out


def main():
    os.makedirs(OUT, exist_ok=True)

    bg = load_layer("background.png", TARGET)
    # 背景层必须不透明：设计稿背景已满幅，若含 alpha 则压到不透明
    if bg.getchannel("A").getextrema()[0] < 255:
        flat = Image.new("RGBA", bg.size, (0x34, 0x86, 0xD8, 255))
        flat.alpha_composite(bg)
        bg = flat
    fg = load_layer("foreground.png", TARGET, scale=FG_SCALE)

    icon = bg.copy()
    icon.alpha_composite(fg)

    bg.save(os.path.join(OUT, "arkdesk_background.png"))
    fg.save(os.path.join(OUT, "arkdesk_foreground.png"))
    icon.save(os.path.join(OUT, "arkdesk.png"))
    icon.resize((216, 216), Image.LANCZOS).save(os.path.join(OUT, "arkdesk-market-216.png"))
    for size in EXPORT_SIZES:
        if size in (1024, 216):
            continue
        icon.resize((size, size), Image.LANCZOS).save(os.path.join(OUT, "arkdesk-%d.png" % size))

    start = rounded(icon, int(round(TARGET * 232.0 / 1024.0)))
    start.resize((144, 144), Image.LANCZOS).save(os.path.join(OUT, "startIcon-144.png"))

    open(os.path.join(OUT, "layered_image.json"), "w", encoding="utf-8").write(
        json.dumps({"layered-image": {
            "background": "$media:arkdesk_background",
            "foreground": "$media:arkdesk_foreground"}},
            ensure_ascii=False, indent=2) + "\n")

    # 启动图标：同一设计 + 系统同款圆角，144pt 视图
    open(os.path.join(OUT, "startIcon.svg"), "w", encoding="utf-8").write(
        '<svg xmlns="http://www.w3.org/2000/svg" width="144" height="144" viewBox="0 0 1024 1024">\n'
        '  <defs>\n'
        '    <clipPath id="startClip"><rect x="0" y="0" width="1024" height="1024" rx="232" ry="232"/></clipPath>\n'
        '  </defs>\n'
        '  <image href="arkdesk.png" x="0" y="0" width="1024" height="1024" '
        'clip-path="url(#startClip)" preserveAspectRatio="xMidYMid slice"/>\n'
        '</svg>\n')

    print("OK -> %s" % OUT)
    for n in sorted(os.listdir(OUT)):
        if n.startswith(("arkdesk", "layered", "startIcon")):
            print("   %s (%d B)" % (n, os.path.getsize(os.path.join(OUT, n))))
    return 0


if __name__ == "__main__":
    sys.exit(main())
