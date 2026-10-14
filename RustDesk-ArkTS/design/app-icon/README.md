# ArkDesk 应用图标 —— 设计稿与资源生成

> 状态：**已接入工程并装机验证**（2026-10-14）
> bundleName `cloud.xhenr.arkdesk` ｜ 应用名 **ArkDesk** ｜ 版本 **0.9.0**

---

## 1. 设计稿

| 文件 | 说明 |
|---|---|
| [background.svg](background.svg) | 背景层矢量母版（CorelDRAW 导出，256mm 画布，`viewBox 0 0 25596.8 25596.8`） |
| [foreground.svg](foreground.svg) | 前景层矢量母版：显示屏 + 字母 A + 在线光点 |
| [background.png](background.png) | 背景层位图（265×265） |
| [foreground.png](foreground.png) | 前景层位图，透明底（256×256） |

**概念**：圆角显示屏内嵌 ArkDesk 首字母 **A**（横杆以屏幕底色镂空成负形），右上角薄荷绿联机光点，
底部为显示屏支架。配色取自 `docs/UI配色规范.md`：背景天空蓝渐变、A 字 `#2A6DB5`、光点 `#7BF0CE → #33CB9C`。

---

## 2. 生成鸿蒙分层图标资源

```powershell
$py = 'C:\Users\WLX\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe'
& $py 'E:\Code\RustDesk-homs\RustDesk-ArkTS\design\app-icon\build_from_design.py'
```

默认输出到本目录；用 `ARKDESK_OUT` 可改到别处：

```powershell
$env:ARKDESK_OUT = 'E:\some\writable\dir'
```

产出：

| 文件 | 规格 | 用途 |
|---|---|---|
| `arkdesk_background.png` | 1024×1024 不透明 | 分层图标背景层 |
| `arkdesk_foreground.png` | 1024×1024 透明底 | 分层图标前景层 |
| `arkdesk.png` | 1024×1024 | 兜底 / 直角版本 |
| `arkdesk-market-216.png` | 216×216 | AGC 上架用 |
| `arkdesk-{512,216,144,96,72,48,36}.png` | 各尺寸 | 预览 / 其他渠道 |
| `startIcon.svg` + `startIcon-144.png` | 144pt + 系统圆角 r232 | 启动页 `startWindowIcon` |
| `layered_image.json` | 分层声明 | 组合为 `$media:layered_image` |

> 设计稿只有 256/265 px，脚本会**用 LANCZOS 放大到 1024**。
> 若要更锐利的小尺寸表现，建议从 CorelDRAW 直接导出 1024×1024 PNG 后重跑本脚本。
> 前景层按 `FG_SCALE = 0.86` 居中缩放，以保持与设计稿一致的安全区留白。

---

## 3. 已接入的位置

| 文件 | 改动 |
|---|---|
| `AppScope/resources/base/media/` | 新增 `arkdesk_background.png`、`arkdesk_foreground.png`、`arkdesk.png`、`layered_image.json`、`startIcon.svg` |
| `entry/src/main/resources/base/media/` | 同上五件 |
| `AppScope/app.json5` | `icon`: `$media:resk` → `$media:layered_image` |
| `entry/src/main/module.json5` | 两个 ability 的 `icon` → `$media:layered_image` |
| `SettingsTab.ets`（关于卡） | `$r('app.media.resk')` → `$r('app.media.arkdesk')` |
| `RustDeskIndex.ets`（多窗标题栏） | 同上 |
| 旧资源 | 已删除 `resk.png`、`resk_background.png`、`resk_foreground.png` |

---

## 4. 验证记录

- ✅ `hvigorw assembleHap`（debug）**BUILD SUCCESSFUL**
- ✅ 安装到 nova 12 Ultra（`3BPUT24604002714`）成功，`bm dump` 确认：
  `cloud.xhenr.arkdesk` ｜ vendor `arkdesk` ｜ versionCode `9000000` ｜ provision `debug`
- ✅ 签名后的 HAP 内 `module.json` 三处 `icon` 均为 `$media:layered_image`
- ✅ 桌面图标正常显示（白色 A + 显示器 + 绿色光点）
- ✅ 设置 →「诊断与关于」显示 **ArkDesk / 版本 0.9.0**，图标为新图标
- ✅ 无崩溃日志
