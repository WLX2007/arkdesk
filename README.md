# ArkDesk — HarmonyOS 原生远程桌面客户端

> 版本 **0.9.0** ｜ 基于 [FrankHan052176/RustDesk-ArkTS](https://github.com/FrankHan052176/RustDesk-ArkTS)（RustDesk OHOS 移植）二次开发的鸿蒙原生远程控制客户端。
> 应用标识：`top.frankhan.arkdesk` ｜ URL Scheme：`arkdesk://` ｜ 底层协议内核仍为 RustDesk。

## 仓库结构

| 目录 | 说明 |
|---|---|
| `RustDesk-ArkTS/` | 鸿蒙 ArkTS 壳工程（主工程，DevEco Studio 打开此目录） |
| `RustDeskHar/` | Rust 内核 → HAR 桥接工程（构建 rustdesk-ohrs.har 用） |
| `rustdesk4ohos/` | RustDesk Rust 内核 OHOS fork（上游 submodule 源） |
| `deveco-cli/` | 华为官方 deveco-cli 源码参考 |
| `docs/` | UI 结构分析报告、配色规范文档 |
| `luminous_neo_stubs/` | luminous_neo UI 库本地替身（源码已内置到主工程） |

## 主要改造（相对上游）

- 全局配色重做为 **#3486D8** 主题色体系（见 `docs/UI配色规范.md`）
- 首页重构：扁平卡片布局、连接模式收编为图标+底部弹窗
- 设备页重构：搜索入口上移页头、切换栏无副标题、新版设备卡片
- 页头统一为官方 HdsNavigation（仅主标题），Tab 顺序：首页/服务端/设备/设置
- luminous_neo UI 库以源码形式内置（`entry/src/main/ets/luminous_neo/`）

## 构建与运行

```powershell
# 环境：DevEco Studio 26+ / JDK(JBR) / ohpm / hvigor
cd RustDesk-ArkTS
ohpm install
hvigorw assembleHap -p product=default -p buildMode=debug
# 产物: entry/build/default/outputs/default/entry-default-signed.hap
hdc install -r entry\build\default\outputs\default\entry-default-signed.hap
```

签名：`build-profile.json5` 已配置自动签名材料（本机路径），首次构建需在 DevEco 中重新生成。

## 许可

遵循上游 AGPL-3.0。
