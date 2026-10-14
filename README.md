# ArkDesk — HarmonyOS 原生远程桌面客户端

> 版本 **0.9.0** ｜ 基于 RustDesk（AGPL-3.0）构建的鸿蒙原生远程控制客户端。
> 应用标识：`cloud.xhenr.arkdesk` ｜ URL Scheme：`arkdesk://` ｜ 底层协议内核为 RustDesk。

> **非官方声明**：ArkDesk 为社区独立开发的非官方客户端，与 RustDesk 官方（Purslane Ltd）无隶属或代言关系。

## 主要特性

- 远程查看与控制 Windows / macOS / Linux 设备（触屏手势 + 软键盘）
- 文件与图片双向传输、多显示器切换、画质预设
- 支持自建 ID / 中继服务器，数据不经第三方
- 可选 EasyTier 预组网，简化内网设备直连
- 支持手机 / 平板 / 2in1（PC）形态

## 仓库结构

| 目录 | 说明 |
|---|---|
| `RustDesk-ArkTS/` | 鸿蒙 ArkTS 壳工程（主工程，DevEco Studio 打开此目录） |
| `RustDeskHar/` | Rust 内核 → HAR 桥接工程（构建 rustdesk-ohrs.har 用） |
| `rustdesk4ohos/` | RustDesk Rust 内核 OHOS fork（上游 submodule 源） |
| `store-listing/` | 应用市场上架文案、隐私政策与合规清单 |
| `deveco-cli/` | 华为官方 deveco-cli 源码参考 |
| `docs/` | UI 结构分析报告、配色规范文档 |
| `luminous_neo_stubs/` | luminous_neo UI 库本地替身（源码已内置到主工程） |

## 构建与运行

```powershell
# 环境：DevEco Studio 26+ / JDK(JBR) / ohpm / hvigor
cd RustDesk-ArkTS
ohpm install
hvigorw assembleHap -p product=default -p buildMode=debug
# 产物: entry/build/default/outputs/default/entry-default-signed.hap
hdc install -r entry\build\default\outputs\default\entry-default-signed.hap
```

## 隐私

- 隐私政策：<https://wlx2007.github.io/arkdesk/privacy-policy-zh-CN>（`store-listing/site/`，经 GitHub Pages 发布）
- 本应用不集成任何统计/广告 SDK，开发者不收集任何用户数据。

## 许可

本应用基于 RustDesk 修改，依据 **[GNU AGPL-3.0](LICENSE)** 许可证分发：

- 本仓库包含修改版的完整对应源码（Rust 核心、HAR 桥、ArkTS 应用）；
- 原项目版权归 RustDesk 贡献者所有，许可全文见 [LICENSE](LICENSE)。
