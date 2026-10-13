# RustDesk 鸿蒙客户端 — UI 结构全景分析报告

> 生成时间：2026-10-13 22:07 · 基于 commit `9b7bf4a1`（RustDesk-ArkTS main）
> 分析范围：`entry/src/main/ets/` 全部 34 个 ETS 文件 + 资源 token 体系
> 用途：UI 优化改造前的结构基线文档，配合后续优化决策使用

---

## 一、总体架构鸟瞰

```
RustDeskIndex.ets（9038 行 / 338KB ⚠️ 巨型上帝页面）
├── 128 个 @Local/@Param 响应式状态
├── 349 个方法（业务+UI+手势+网络混杂）
├── 27 个 @Builder 局部视图
│
├── 导航层：宽屏 WideNavigationRail（侧栏）/ 窄屏 HdsTabs（底部4 Tab）
│   ├── Tab0 首页(连接) → ConnectTab
│   ├── Tab1 设备 → DeviceDirectoryPanel
│   ├── Tab2 设置 → SettingsTab
│   └── Tab3 服务端 → ViewedHostPage
│
├── 会话层（全屏接管）：remotePreviewPane (XComponent) + SessionToolbar
├── 工作台层：transferWorkspaceBuilder → TransferDrawer
├── 浮层群：ConnectionAttemptOverlay / PasswordDialog / InsecureConnectionDialog / PreviewModal
└── 抽屉群：ChatDrawer / DisplaySelectorSheet / QualityControlSheet / InputModeSheet
```

### 页面切换机制

- **宽屏（2in1/平板/自由多窗）**：`WideNavigationRail` 左侧栏 + `SelectedMainPage()` 按 `currentTabIndex` 条件渲染，页面切换用 translate+opacity 非对称转场
- **窄屏（手机）**：`HdsTabs` 底部悬浮 TabBar（4 Tab，barOverlap），滑动禁用（`scrollable(false)`），切换动画 280ms
- **手机竖屏**额外包一层 `HdsNavigation` MINI 标题栏（渐变模糊滚动效果）
- **会话激活时**：`showPreviewModal` / `showTransferWorkspace` 分支直接接管 `MainContent()`，全屏覆盖导航

### 主页面 27 个 Builder 清单（RustDeskIndex.ets）

| Builder | 行号 | 职责 |
|---|---|---|
| androidNavigationOverlay | - | 安卓风格导航条浮层 |
| remoteSessionResumeOverlay | - | 会话恢复悬浮条 |
| remotePreviewPane | 7403 | **远控画面核心渲染**（XComponent + 输入捕获） |
| previewMiniBar | - | 预览迷你条 |
| FoldControlButton / foldHoverControlPane | - | 折叠屏控制按钮 |
| chatOverlayPanel | - | 聊天浮层 |
| RootFloatingAction | - | 根级悬浮按钮 |
| transferWorkspaceBuilder | - | 文件传输工作台入口 |
| displayOverlayPanel / qualityOverlayPanel | - | 显示器/画质二级面板 |
| ConnectPageContent / DevicesPageContent / SettingsPageContent / ViewedHostPageContent | - | 四个 Tab 内容装配 |
| WideNavigationItem / WideRailIdentity / WideNavigationRail | - | 宽屏侧栏 |
| previewModalBuilder | - | 预览模态 |
| TabBuilder | 8657 | 底部 Tab 项 |
| FreeWindowTitleBar / FreeWindowTitleBarStack | - | 自由窗标题栏 |
| SelectedMainPage / CompactMainTabs | - | 页面选择器（宽/窄） |
| MainNavigationBody / MainNavigationPane / MainContent | - | 导航骨架 |

### zIndex 浮层层级（现状，魔法数字）

| 组件 | zIndex |
|---|---|
| MainContent | 1 |
| WideNavigationRail | 10 |
| ConnectionAttemptOverlay | 1500 |
| PasswordDialog | 2000 |
| InsecureConnectionDialog | 2100 |

---

## 二、逐页面/组件文档分析

### 🏠 P1. 首页/连接页 — `components/ConnectTab.ets`

**规模**：651 行 / 20.7KB

**职责**：输入目标 ID → 选择连接模式 → 发起连接

**UI 结构**：
```
ConnectTab
├── 连接模式 SegmentedControl（远程控制 / 只看屏幕 / 查看相机 / 文件传输）
├── 目标输入框（LuminousTextField + placeholder"输入设备 ID"）
├── EasyTier 预组网 SecondaryMenu（直连/实例列表，可折叠）
├── 断开按钮（canDisconnect 时）
└── 最近设备区（横滑卡片）
```

**状态与通信**：11 @Param + 3 @Local，17 个回调事件全部上传至 Index 处理

**问题**：
1. 单列长滚动，无视觉锚点，首屏信息密度低
2. EasyTier 陌生概念与主连接流程混排，干扰普通用户
3. 「最近连接」入口在窄屏被挤压，太弱
4. 「文件传输」选项实际跳转独立工作台，与其他三个"会话内模式"交互层级不一致

### 📱 P2. 设备页 — `components/DeviceDirectoryPanel.ets` + `PeerCard.ets`

**规模**：640 行 / 20.1KB + 360 行 / 10.8KB

**职责**：设备目录，四来源：最近 / 收藏 / 局域网 / 通讯录

**UI 结构**：
```
DeviceDirectoryPanel
├── 来源 SegmentedControl（recent/favorite/lan/address-book）
├── 搜索框（LuminousSearchField）
└── 设备卡片列表 ×4（每个来源独立 Scroller！）
    └── PeerCard：LuminousSurface 拟态面 + 设备信息 + 4 个连接模式快捷图标
```

**状态**：8 @Param + 1 @Local + **4 个独立 Scroller 实例**

**问题**：
1. 4 个 Scroller 说明各来源是独立列表拼接，切换来源滚动位置丢失
2. PeerCard 上 4 个快捷操作图标并排，辨识度低
3. 空状态设计简陋（"这里还没有设备"纯文本）
4. 无分组/批量管理能力

### ⚙️ P3. 设置页 — `components/SettingsTab.ets` ⚠️ 第二大文件

**规模**：1210 行 / 40.7KB（不含四张子卡片）

**职责**：聚合 4 张巨型设置卡片

| 子卡片 | 规模 | @Param/@Builder | 内容 |
|---|---|---|---|
| `ServerSettingsCard` | 745行 / 24.4KB | 4 / 10 | ID/Relay/API 服务器与 Key 配置、测试连通性 |
| `AccountSettingsCard` | 969行 / 28.9KB | 3 / 20 | 登录方式、账号信息 |
| `SessionDefaultsCard` | 782行 / 24.3KB | 3 / 13 | 默认输入模式/画质/编码等会话偏好 |
| `HostSecuritySettingsCard` | 582行 / 22.1KB | 2 / 4 | 被控端：访问密码、双重认证 |

**问题**：
1. 单文件 40KB 聚合 4 卡片，设置页是最重改造点
2. 卡片 Section 视觉节奏不一致（有的有 SectionHeading 有的没有）
3. 设置项无搜索、无分组导航锚点
4. 被控端（HostSecurity）与控制端（SessionDefaults）关注点混在同一层

### 🖥️ P4. 服务端页 — `components/ViewedHostPage.ets` + `ViewedHostCard.ets`

**规模**：112 行 + 324 行 / 10.5KB

**问题**：
1. Tab 名「服务端」但内容是"本机被观看状态"，语义错位
2. 页面极薄（112 行），与 Tab 地位不匹配
3. 「服务器与网络」配置弹窗入口实际挂在这里（截图验证）

### 🎛️ P5. 会话中 UI（远控全屏层）

**remotePreviewPane**（Index 内 ~200 行）：
- XComponent(SURFACE) 视频流 + RGBA fallback Image 双通道渲染
- 全屏透明 Button 作输入捕获（键盘/鼠标/触摸/滚轮四类事件**全部内联在 Index**，是 Index 膨胀根源之一）
- 缩放/旋转/平移三组 transform 参数叠加

**SessionToolbar.ets**（925 行 / 31.3KB）⚠️：
- 顶部悬浮工具栏：会话 Tab 切换 + 触摸/鼠标模式 + 键盘 + 聊天 + 文件 + 显示器 + 画质 + 断开
- **16+ 按钮平铺一行**，窄屏溢出策略不明
- 二级面板 DisplaySelectorSheet(230行) / QualityControlSheet(257行) / InputModeSheet(320行) 三者各自实现，无统一容器

**TransferDrawer.ets**（963 行 / 30.3KB）：
- 双栏文件管理器（本机/远端），独立工作台覆盖整个导航
- 手机窄屏双栏挤压严重
- 传输队列、冲突覆盖对话框耦合同文件

### 💬 P6. 浮层/对话框/其余组件

| 组件 | 规模 | 备注/问题 |
|---|---|---|
| ConnectionAttemptOverlay | 229行 / 6.9KB | 连接全屏遮罩，zIndex 1500 |
| PasswordDialog | 229行 / 7.6KB | 密码+2FA 双模式，zIndex 2000；自绘弹窗与系统风格并存 |
| InsecureConnectionDialog | 158行 / 5.2KB | zIndex 2100 |
| ChatDrawer | 179行 / 5.8KB | 最轻量，结构尚可 |
| PreviewModal | 100行 / 3.2KB | - |
| RemoteSoftKeyboard | 591行 / 19.6KB | 自绘软键盘，按键布局硬编码 |
| BeginnerGuidePage | 415行 / 13.1KB | 新手引导，0 @Param（静态） |
| StatusPage | 115行 / 3.5KB | 会话状态页 |
| FloatingSurface / FloatingDepth / FloatingSegmentedControl | 287+81+101行 | 拟态容器封装（依赖 luminous_neo 替身） |
| AndroidNavigationBar | 92行 | 底部导航条适配 |
| SessionInputControls / ToolbarTripleSelector / SessionPanelFrame / RemoteSessionWorkspace | 小型 | 会话辅助件 |

---

## 三、设计 Token 体系审查

### 🎨 色彩（color.json 68 tokens，dark/ 68 tokens 镜像）

**三套色彩语言并存**：

| 体系 | 代表 token | 风格来源 |
|---|---|---|
| Mica/Glass 系 | mica_surface, mica_control, glass_surface... | Windows Fluent |
| Neu 拟态系 | neu_base, neu_shadow_dark/light... | luminous_neo 私有库 |
| 通用语义系 | brand_primary, text_*, success/warning/error... | 常规 |

关键值：
```
neu_base          #F3F4F6（浅灰底）
brand_primary     #087E8B（青绿 — 官方强调色）
hero_start/mid/end #34429D→#5261D6→#237F91（深蓝渐变 — 截图中主按钮实际用色）
text_primary      #001F3F（深藏青）
text_tertiary     #7A8996 ⚠️ 对比度 ~3.4:1 < WCAG AA 4.5:1
```

**问题清单**：
1. 同一页面可能同时引用三套色，主题切换易漏
2. 品牌色分裂：brand_primary（青绿）vs hero 系（蓝紫）并存，主按钮视觉不统一
3. text_tertiary 对比度不达标
4. 遗留孤儿色（surface_inverse、tabs_gradient_mask 等）

### 📏 间距/字号/圆角（float.json 42 tokens）

- 有 space_8/12/24 标准间距 token
- **但组件内大量魔法数字**：`padding({left:10,right:10})`、圆角 `14/16/18/19/20/21/22/24` 八个近似值全在用
- 字号经 $r('app.float.font_*') 引用，尚可

### 🌓 深色模式

- `resources/dark/element/color.json` 存在，68 token 全量镜像 ✅
- 风险：`neu_shadow_light = #FFFFFF` 等白系硬编码在深色下的替换需逐个核对

### 布局断点（RustDeskLayoutTokens.ets）

```ts
WIDE_CONTENT_EDGE = 32; PAGE_TITLE_SPACER = 96;
PAGE_CONTENT_TOP_PADDING = 18; HOME_TWO_COLUMN_MIN_WIDTH = 980;
// 断点逻辑分散：mainViewportWidth >= 840、isWideMainLayout() 等多处各自判断
```

---

## 四、结构性问题总结（按严重度排序）

| # | 问题 | 影响 | 改造入口 |
|---|---|---|---|
| 1 | **RustDeskIndex 9038 行上帝文件**：128 状态+349 方法+27 Builder，会话手势/事件全部内联 | 任何 UI 改动都在巨型文件里进行，极难维护 | Index 拆分（状态管理+会话手势层抽离） |
| 2 | **视觉语言三套并存**（Mica / Neu 拟态 / 扁平替身） | 当前 UI 是「私有拟态库+扁平替身」混合体，风格割裂 | color.json + luminous_neo_stubs 统一 |
| 3 | **设置页 4 卡片 3000+ 行无分组导航** | 找设置项靠滚动 | SettingsTab 重排 |
| 4 | **zIndex/圆角/间距魔法数字** | 一致性差 | 建 token 表收口 |
| 5 | **Tab 语义错位**：「服务端」名实不符；「文件传输」跳独立工作台层级突兀 | 信息架构混乱 | 导航层重定义 |
| 6 | **会话工具栏 16+ 按钮平铺** | 窄屏可用性差 | SessionToolbar 分组/收纳 |
| 7 | 4 个 Scroller 设备列表、简陋空状态 | 体验割裂 | DeviceDirectoryPanel |

---

## 五、改造入口地图（按投入分级）

```
轻量改造（只动样式 token）
  → entry/src/main/resources/base/element/color.json
  → entry/src/main/resources/base/element/float.json
  → luminous_neo_stubs/（替身组件库，顺带统一视觉）

中量改造（单页重排）
  → components/SettingsTab.ets（+4 张卡片）
  → components/SessionToolbar.ets
  → components/ConnectTab.ets

重量改造（架构级）
  → pages/RustDeskIndex.ets 拆分：
      · 会话输入处理层（手势/键鼠事件）→ 独立 controller
      · 27 个 Builder → 按域拆子组件
      · 128 个状态 → 聚合 state model

信息架构级
  → 导航 Tab 重定义（服务端页归位、文件传输入口收编进会话）
  → 断点系统统一（收口到 RustDeskLayoutTokens）
```

---

## 附录 A：文件清单（UI 相关，按规模排序）

| 文件 | 行数 | 大小 |
|---|---|---|
| pages/RustDeskIndex.ets | 9038 | 338.3KB |
| components/SettingsTab.ets | 1210 | 40.7KB |
| components/SessionToolbar.ets | 925 | 31.3KB |
| components/TransferDrawer.ets | 963 | 30.3KB |
| components/AccountSettingsCard.ets | 969 | 28.9KB |
| components/ServerSettingsCard.ets | 745 | 24.4KB |
| components/SessionDefaultsCard.ets | 782 | 24.3KB |
| components/HostSecuritySettingsCard.ets | 582 | 22.1KB |
| components/ConnectTab.ets | 651 | 20.7KB |
| components/DeviceDirectoryPanel.ets | 640 | 20.1KB |
| components/RemoteSoftKeyboard.ets | 591 | 19.6KB |
| components/PeerCard.ets | 360 | 10.8KB |
| components/ViewedHostCard.ets | 324 | 10.5KB |
| components/InputModeSheet.ets | 320 | 10.5KB |
| components/BeginnerGuidePage.ets | 415 | 13.1KB |
| components/FloatingSurface.ets | 287 | 8.8KB |
| components/QualityControlSheet.ets | 257 | 8.2KB |
| components/DisplaySelectorSheet.ets | 230 | 8.1KB |
| components/PasswordDialog.ets | 229 | 7.6KB |
| components/ConnectionAttemptOverlay.ets | 229 | 6.9KB |
| components/ChatDrawer.ets | 179 | 5.8KB |
| components/InsecureConnectionDialog.ets | 158 | 5.2KB |
| components/StatusPage.ets | 115 | 3.5KB |
| components/PreviewModal.ets | 100 | 3.2KB |
| components/RemoteMediaPanel.ets | ~100 | 3.9KB |
| components/SessionPanelFrame.ets | 75 | 2.4KB |
| components/RemoteSessionWorkspace.ets | 52 | 1.7KB |
| components/FloatingDepth.ets | 81 | 2.2KB |
| components/FloatingSegmentedControl.ets | ~90 | 3.5KB |
| components/ToolbarTripleSelector.ets | ~60 | 2.5KB |
| components/SessionInputControls.ets | ~140 | 5.6KB |
| components/AndroidNavigationBar.ets | 92 | 2.9KB |

## 附录 B：真机验证环境

- 设备：nova 12 Ultra 星耀版（HarmonyOS），序列号 3BPUT24604002714
- 签名：自动签名（`build-profile.json5` product.default.signingConfig）
- 构建命令：`hvigorw assembleHap -p product=default -p buildMode=debug`
- 当前已知：远控连接流程已跑通（自建服务器 113.195.80.39，Key mismatch 已修复）
- UI 现状：luminous_neo 为本地扁平替身（`luminous_neo_stubs/`），私有原版 UI 库未开放
