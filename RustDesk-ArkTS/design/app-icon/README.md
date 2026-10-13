# Resk 鸿蒙版应用图标设计

> 目标工程：`RustDesk-ArkTS`（bundleName `top.frankhan.resk`，应用名 **Resk**）
> 设计语言：对齐 `docs/UI配色规范.md`（主色 `#3486D8` 天空蓝 · 扁平现代 + 轻拟态）
> 交付日期：2026-10-14 ｜ 全部几何为矢量手绘，无第三方素材

---

## 1. 交付清单

| 文件 | 说明 |
|---|---|
| [预览-方案对比.png](预览-方案对比.png) | 三方案在亮色/深色桌面、96/72/48/36px 下的对比 |
| [预览-推荐方案.png](预览-推荐方案.png) | 推荐方案（A）的尺寸阶梯 + 图层拆解 |
| [方案A-品牌蓝R/](方案A-品牌蓝R/) | 方案 A 矢量母版（background.svg / foreground.svg / icon.svg）+ 1024~48px PNG |
| [方案B-暗夜光感R/](方案B-暗夜光感R/) | 方案 B 同上 |
| [方案C-屏幕互联/](方案C-屏幕互联/) | 方案 C 同上 |
| [交付-方案A/](交付-方案A/) | 可直接拷入工程的资源：`resk_background.png`、`resk_foreground.png`、`layered_image.json`、`resk.png`、`resk-market-216.png`、`startIcon.svg` |
| [_pipeline/build.py](_pipeline/build.py) | 一键重建：SVG → 图层 PNG → 合成 → 全尺寸导出 → 预览图 → 交付资源 |
| [_backup/](_backup/) | 改造前的旧图标原件（回滚用） |

---

## 2. 方案对比与取舍

| 方案 | 概念 | 优势 | 风险 |
|---|---|---|---|
| **A · 品牌蓝 R + 在线光点**（推荐） | 圆形几何字 "R" + 薄荷绿联机点，天空蓝 135° 渐变底 | 品牌延续（沿用 R 字识别）、小尺寸最清晰、亮暗桌面都在线 | 变化幅度偏"演进"而非"颠覆" |
| B · 暗夜光感 R | 深色底 + 发光字形 | 高级感强，贴合深色/沉浸光感 | 深色图标在深色壁纸上对比弱，48px 下偏灰 |
| C · 屏幕互联 | 显示器 + 光标 + 联机点 | 功能直述，陌生用户一眼懂 | 元素多，36px 已接近不可辨；品牌符号弱 |

**采用 A**：图标是"最小尺寸下还能被认出"的资产，A 在 36px 仍能读出 R 与光点，且与 `#3486D8` 主色体系一致（见第 4 节数据）。

---

## 3. 推荐方案 A 设计规范

### 3.1 画布与安全区（1024 × 1024 母版）

```
画布            1024 × 1024 px
主体安全区      x 200–824, y 200–824（居中 61%，适配鸿蒙圆角裁切与前景视差）
字面            cap height 420（y 296–716），笔画 112（≈11% 画布）
笔画端点        圆头 / 圆角连接（round cap · round join）
字形 bbox       x 284–728, y 240–772（含描边）
联机点          r 62，圆心 (740, 300)，外发光 r 124
整体构图 bbox   x 252–773, y 246–778 → 视觉中心 (512, 512)
```

字形骨架（`foreground.svg` 中的三条路径，描边 112）：

```svg
<path d="M340 716 V296 H500 a130 130 0 0 1 0 260 H340"/>   <!-- 竖笔 + 上横 + 字碗 + 下横 -->
<path d="M500 556 L686 716"/>                               <!-- 右腿 -->
<circle cx="740" cy="300" r="62"/>                          <!-- 联机光点 -->
```

### 3.2 配色（全部取自项目 token）

| 元素 | 值 | 来源 token |
|---|---|---|
| 背景渐变（135°） | `#4FA6EE` → `#3486D8`(52%) → `#2A6DB5` | `hero_start/mid/end` |
| 背景高光 | 白色 30% → 0（左上径向） | `neu_shadow_light` 语义 |
| 背景纵深 | `#123A63` 34% → 0（右下径向） | `text_primary` 同色相 |
| 字形 | `#FFFFFF` → `#E2EEFB` | `hero_text` |
| 字形投影 | `#123A63` 18%，dy 18 / blur 22 | 冷阴影规范 |
| 联机光点 | `#7BF0CE` → `#33CB9C` | `success` 语义系 |

> 联机点语义：表示"对端在线 / 连接建立"，与界面上的 `success #1F9D6C` 同一语义族，取更亮的薄荷值以保证在蓝色底上的可见度。

### 3.3 图层分工（鸿蒙分层图标）

- **背景层**：满幅渐变，不含任何主体元素，不做圆角（系统统一裁切）。
- **前景层**：字形 + 联机点，透明底，主体居于安全区中心，不含圆角/内边距/背景色。

---

## 4. 对比度数据

| 前景 / 背景 | 比值 | 结论 |
|---|---|---|
| `#FFFFFF` / `#3486D8` | 3.79 : 1 | 大图形元素 ≥ 3:1，达标 |
| `#E2EEFB` / `#2A6DB5` | 4.52 : 1 | 达标 |
| `#FFFFFF` / `#2A6DB5` | 5.31 : 1 | 达标 |
| `#4FE0B0` / `#3486D8` | 2.28 : 1 | 装饰性品牌点缀（Logo 元素豁免 1.4.11），靠明度 + 色相差辨识 |
| `#4FE0B0` / `#0B1420`（方案 B） | 11.12 : 1 | 达标 |

---

## 5. 鸿蒙工程接入（已完成）

### 5.1 资源规范

| 资源 | 规格 | 用途 |
|---|---|---|
| `resk_background.png` | 1024×1024 PNG（不透明） | 分层图标背景层 |
| `resk_foreground.png` | 1024×1024 PNG（透明底、无自查圆角） | 分层图标前景层 |
| `layered_image.json` | `{"layered-image":{"background":"$media:resk_background","foreground":"$media:resk_foreground"}}` | 把两层组合为 `$media:layered_image` |
| `resk.png` | 1024×1024 PNG（真实 PNG，替代旧的 JPEG 伪装 png） | 兜底/直角版本 |
| `startIcon.svg` | 144×144 视图，系统同款圆角 | 启动页 `startWindowIcon` |
| `resk-market-216.png` | 216×216 直角 PNG | AGC 上架用图标 |

### 5.2 已改动文件

| 文件 | 改动 |
|---|---|
| `AppScope/resources/base/media/` | 新增 `resk_background.png`、`resk_foreground.png`、`layered_image.json`；`resk.png` 换新；`app_icon.svg` 换新（矢量母版） |
| `entry/src/main/resources/base/media/` | 同上四件 + `startIcon.svg` 换新 |
| `AppScope/app.json5` | `icon`: `$media:resk` → `$media:layered_image` |
| `entry/src/main/module.json5` | 两个 ability 的 `icon`: `$media:resk` → `$media:layered_image` |

### 5.3 回滚

```powershell
$bk   = 'E:\Code\RustDesk-homs\RustDesk-ArkTS\design\app-icon\_backup'
$proj = 'E:\Code\RustDesk-homs\RustDesk-ArkTS'
Copy-Item "$bk\AppScope_resk.png"     "$proj\AppScope\resources\base\media\resk.png" -Force
Copy-Item "$bk\AppScope_app_icon.svg" "$proj\AppScope\resources\base\media\app_icon.svg" -Force
Copy-Item "$bk\entry_resk.png"        "$proj\entry\src\main\resources\base\media\resk.png" -Force
Copy-Item "$bk\entry_startIcon.svg"   "$proj\entry\src\main\resources\base\media\startIcon.svg" -Force
# 再把 app.json5 / module.json5 的 icon 改回 $media:resk
Remove-Item "$proj\AppScope\resources\base\media\layered_image.json" -Force
Remove-Item "$proj\entry\src\main\resources\base\media\layered_image.json" -Force
```

---

## 6. 重新生成 / 微调

```powershell
cd 'E:\Code\RustDesk-homs\RustDesk-ArkTS\design\app-icon'
& 'C:\Users\WLX\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe' '_pipeline\build.py'
```

- 改设计 → 编辑对应方案的 `background.svg` / `foreground.svg` → 重跑脚本，所有 PNG、预览图、交付资源一起更新。
- 渲染用 Edge 无头模式（透明背景、精确 1024×1024），预览合成用 Pillow（LANCZOS + 22.5% 系统圆角模拟）。

---

## 7. 验证记录

- ✅ `hvigorw assembleHap`（debug）构建通过；`entry-default-signed.hap` 内已打包 `resources/base/media/{resk_background.png, resk_foreground.png, layered_image.json, resk.png, startIcon.svg}`，`module.json` 中两个 ability 的 `icon` 均为 `$media:layered_image`。
- ✅ `hdc install` 覆盖安装成功（bundle `top.frankhan.resk`）。
- ℹ️ 打包时资源编译会把两层图标压到 512×512（`resk_background.png` 131 KB / `resk_foreground.png` 60 KB），`resk.png` 保持 1024×1024；桌面图标实际渲染尺寸 ≤ 288 px，512 源图足够。
- ⏳ 桌面实际显示效果待设备解锁后在桌面确认（安装时设备处于锁屏，未做界面操作）。

---

## 8. 切换到方案 B / C

配置与文件清单不变，只替换两层图片即可：

```powershell
$proj = 'E:\Code\RustDesk-homs\RustDesk-ArkTS'
$src  = "$proj\design\app-icon\方案C-屏幕互联"     # 换成方案B-暗夜光感R / 方案C-屏幕互联
foreach ($d in @("$proj\AppScope\resources\base\media", "$proj\entry\src\main\resources\base\media")) {
  Copy-Item "$src\background.png" "$d\resk_background.png" -Force
  Copy-Item "$src\foreground.png" "$d\resk_foreground.png" -Force
  Copy-Item "$src\icon-1024.png"  "$d\resk.png" -Force
}
```
