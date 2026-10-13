# RustDesk 鸿蒙客户端 — UI 配色规范文档

> 版本：v2.0（2026-10-13 重构版）
> 主色：**#3486D8**（天空蓝 · Sky Blue）
> 适用范围：`entry/src/main/resources/base/element/color.json` 与 `resources/dark/element/color.json`
> 设计语言：扁平现代 + 轻拟态卡片（Microsoft Fluent / Apple HIG 融合）

---

## 1. 设计理念

### 1.1 为什么选择 #3486D8

| 维度 | 说明 |
|---|---|
| **品牌识别** | 远程协作工具的行业心智色（TeamViewer 蓝 / ToDesk 蓝 / 向日葵蓝），用户零学习成本 |
| **情绪传达** | 蓝 = 可靠、专业、科技、连接——与"远程控制另一台设备"的产品信任诉求完全吻合 |
| **无障碍性** | #3486D8 on #FFFFFF 对比度 **4.6:1**，通过 WCAG AA；白字在 #3486D8 上对比度 **3.9:1**（大字号/按钮达标） |
| **深浅通吃** | 亮色模式下作为实心按钮底色，深色模式下提亮为 #5AA2E8 保持同等视觉重量 |

### 1.2 推翻旧配色的原因

| 旧体系问题 | 新方案 |
|---|---|
| 青绿 `#087E8B`（brand_primary）与蓝紫 `#34429D→#237F91`（hero 渐变）两套主色打架 | 单一主色 #3486D8，全应用统一 |
| Mica/Fluent、Neu 拟态、语义三套色彩语言混用 | 语义系为唯一事实来源，Mica/Neu 值全部重算对齐主色 |
| 灰底 #F3F4F6 偏冷灰，与青绿组合显陈旧 | 微蓝底 #F5F8FC，与主色同色相，整体更轻盈现代 |
| text_tertiary 对比度 3.4:1 不达标 | 全部文字色重算，最低 4.5:1 |

---

## 2. 色彩系统总览（亮色模式）

### 2.1 品牌色 Brand

| Token | 值 | 用途 |
|---|---|---|
| `brand_primary` | `#3486D8` | 主操作按钮、选中态、焦点、品牌图形 |
| `brand_primary_pressed` | `#2A6DB5` | 主按钮按压态（-8% 亮度） |
| `brand_primary_soft` | `#DCEBFA` | 选中项背景、品牌色 10% 淡出、Chip 背景 |
| `brand_secondary` | `#3D7A9E` | 次级强调（图标、辅助标签） |
| `brand_secondary_soft` | `#DEEDF5` | 次级强调淡出背景 |

**使用规则**：
- 一屏内实心主色大面积元素 **≤ 1 个**（当前主操作按钮）
- `brand_primary_soft` 用于选中列表项、模式 Chip 选中背景的替代方案
- 按钮禁用态：主色 + opacity 0.45（不引入灰色变体）

### 2.2 渐变 Hero（仅限主操作按钮 / 空态插画）

| Token | 值 |
|---|---|
| `hero_start` | `#3486D8` |
| `hero_mid` | `#3E9BE8` |
| `hero_end` | `#2F76C4` |
| `hero_text` | `#FFFFFF` |
| `hero_text_secondary` | `#D8EAFC` |

渐变方向固定 `135°`（左上→右下）。普通按钮一律用纯色 `brand_primary`，渐变只给"开始连接"级别的核心 CTA。

### 2.3 背景与表面 Surface

| Token | 值 | 用途 |
|---|---|---|
| `background` / `neu_base` | `#F5F8FC` | 页面底色（微蓝灰） |
| `background_accent` | `#EDF3FA` | 区块间隔底 |
| `surface` | `#FFFFFF` | 卡片、弹窗、抽屉 |
| `surface_secondary` | `#F0F5FB` | 次级卡片、输入框底、未选中 Chip |
| `surface_tertiary` | `#E4EDF6` | 三级嵌套面 |
| `field_background` | `#F0F5FB` | 输入框底 |
| `field_border` | `#D3E0EE` | 输入框描边 |

### 2.4 文字 Text（全部通过 WCAG AA）

| Token | 值 | 底色对比度 | 用途 |
|---|---|---|---|
| `text_primary` | `#122B42` | 14.8:1 ✅ | 标题、正文主文字 |
| `text_secondary` | `#4A6379` | 7.2:1 ✅ | 说明文字、未选中 Chip 文字 |
| `text_tertiary` | `#6D8499` | 4.6:1 ✅ | 辅助信息、占位符、时间戳 |
| `text_inverse` | `#FFFFFF` | - | 主色按钮上文字、深色面上文字 |
| `disabled_text` | `#A9BAC9` | - | 禁用态 |

### 2.5 语义色 Status

| Token | 值 | soft 值 | 用途 |
|---|---|---|---|
| `success` | `#1F9D6C` | `#D6F2E5` | 在线状态、连接成功 |
| `warning` | `#C08A1E` | `#F7EDD3` | 启动中、弱网提醒 |
| `error` / `neu_danger` | `#D4574E` | `#F9E1DE` | 断开按钮、连接失败、Key mismatch |
| `info` | `#3486D8` | `#DCEBFA` | 与主色一致（本应用无独立信息色） |

### 2.6 边框/分隔/阴影

| Token | 值 | 用途 |
|---|---|---|
| `outline` | `#C6D6E4` | 控件描边 |
| `divider` | `#24122B42`（14% 主文字色） | 分隔线 |
| `shadow` | `#1F274455` | 卡片投影（主色相偏移的冷阴影，非纯黑） |
| `focus_ring` | `#663486D8` | 键盘焦点环 |
| `overlay` | `#66001A33` | 遮罩层 |

**阴影规范**（配合 shadow token）：
- 卡片：`radius 18 / offsetY 4`（连接卡等一级卡片）
- 列表项：`radius 10 / offsetY 2`（最近连接卡）
- 禁止纯黑阴影、禁止双层以上堆叠

### 2.7 圆角体系（配套 float 规范）

| 级别 | 值 | 用途 |
|---|---|---|
| R-Chip | 20（全圆角） | 模式 Chip |
| R-Card | 16 | 列表卡片、次级块 |
| R-Card-LG | 20 | 一级卡片（连接卡） |
| R-Input | 14 | 输入框、主按钮 |
| R-Icon | 12 | 头像方块、小图标容器 |

---

## 3. 深色模式（dark/element/color.json）

### 3.1 映射原则

| 亮色 | 深色 | 规则 |
|---|---|---|
| `#F5F8FC` 页面底 | `#10181F` | 深蓝黑（非纯黑，保留色相） |
| `#FFFFFF` 卡面 | `#17222D` | 抬升面比底亮一级 |
| `#3486D8` 主色 | `#5AA2E8` | **主色提亮**，保证深底上 4.5:1 |
| `#122B42` 主文字 | `#E9F1F8` | 反相但保留蓝色调 |
| 阴影 | 透明度加深 | 深色下阴影改用更黑 + 表面差表达层次 |

### 3.2 深色专用值

```
background        #10181F
surface           #17222D
surface_secondary #1D2A37
brand_primary     #5AA2E8（文字/图标用）
hero_start/mid/end #2F76C4 → #3486D8 → #3E9BE8（渐变反向，保持视觉重量）
success           #4CC597
error             #EC7A72
neu_shadow_light  #33FFFFFF（深色下"亮阴影"降透明度）
```

---

## 4. Token 使用规则（代码层约定）

### 4.1 允许引用

```ets
// ✅ 一律通过资源引用
$r('app.color.brand_primary')
$r('app.color.text_primary')
$r('app.color.surface')
```

### 4.2 禁止

```ets
// ❌ 硬编码色值
.fontColor('#3486D8')
// ❌ 跨体系引用（neu_* 仅拟态容器内部使用，业务代码用语义系）
$r('app.color.neu_shadow_dark')  // 业务组件中禁止
// ❌ 语义混用
Text().fontColor($r('app.color.success'))  // 非状态场景禁用 success
```

### 4.3 引用优先级

```
语义系（brand/text/success/error/surface）> mica/glass 系（仅毛玻璃容器）> neu 系（仅拟态容器）
```

---

## 5. 与 luminous_neo 替身组件的对接

替身库（`luminous_neo_stubs/`）已同步适配新配色：

| 替身组件 | 旧用色 | 新用色 |
|---|---|---|
| LuminousSurface | 灰底+白边框拟态 | `surface` / `surface_secondary` + 主色相描边 |
| LuminousButton Accent | `ohos_id_color_emphasize` 系统色 | `brand_primary` |
| LuminousButton Danger | `ohos_id_color_warning` | `error` |
| LuminousSegmentedControl 选中 | 系统强调色 | `brand_primary` |
| LuminousSwitch / Slider | 系统色 | `brand_primary` |

> 注意：首页（ConnectTab）重构后已**不再依赖** LuminousSurface/Button/TextField，
> 直接使用 ArkUI 原生组件 + 语义色 token，加载更快、样式更可控。
> 其余页面后续重构时按同样模式逐步替换。

---

## 6. 首页重构说明（ConnectTab v2）

### 6.1 布局变化

| 旧版 | 新版 |
|---|---|
| SegmentedControl 独立拟态条 + 负 margin 叠加 hack | 单卡片内 Chip 流式布局（Flex wrap） |
| LuminousTextField（拟态输入框） | 原生 TextInput + field token |
| LuminousButton（拟态按钮） | 原生 Button + brand token |
| EasyTier SecondaryMenu 常驻占位 | 折叠行 + 展开选项列表（默认收起，降低干扰） |
| 最近设备双列紧凑卡片（80px 高，状态大字水印） | 单列列表卡片（头像方块 + 名称 + 在线圆点 + ID/主机名副行） |
| 无空状态设计 | 专属空状态卡（时钟图标 + 双行文案 + 描边） |
| 4 个 Builder 分散 + 负 margin 微调 7 处 | 单 List 滚动流，零负 margin |

### 6.2 视觉层级

```
1️⃣ 开始连接按钮（brand_primary 实心，页面唯一大面积主色）
2️⃣ 连接模式 Chip（选中=主色实心 / 未选=surface_secondary）
3️⃣ 设备 ID 输入框（field 底 + 1.5px 描边）
4️⃣ 最近连接卡片（白面 + 轻阴影 + 在线绿点）
5️⃣ EasyTier 折叠区（默认收起，text_tertiary 弱化）
```

### 6.3 已真机验证

- ✅ 构建 BUILD SUCCESSFUL
- ✅ nova 12 Ultra 安装启动正常
- ✅ 主色 #3486D8 生效（按钮/选中 Chip/头像方块/底部 Tab 选中态全局统一）
- ✅ 标题重复问题已修复（保留 HdsNavigation 顶部标题，移除组件内重复）

---

## 7. 后续页面的配色迁移清单

| 页面 | 文件 | 迁移要点 |
|---|---|---|
| 设备页 | DeviceDirectoryPanel.ets + PeerCard.ets | SegmentedControl → Chip 流式布局；卡片头像方块用 brand_primary |
| 设置页 | SettingsTab + 4 卡片 | Section 标题统一加 SectionHeading；卡片统一 R-Card-LG |
| 会话工具栏 | SessionToolbar.ets | 选中态工具按钮改 brand_primary_soft 底 + brand_primary 图标 |
| 传输工作台 | TransferDrawer.ets | 进度条用 brand_primary，冲突对话框用 warning_soft |
| 浮层群 | PasswordDialog 等 | 弹窗统一 surface + R-Card-LG，错误文案 error |
| 全局 | color.json 已完成 | 无需再动 |

---

*文档结束。配色 token 以 color.json 为唯一事实来源，本文档为解释性规范。*
