# store-listing — 上架与合规材料

本目录存放 ArkDesk 应用市场上架所需的文案、隐私政策与合规文档。

## 文件清单

| 文件 | 用途 |
|---|---|
| [appgallery-listing-zh-CN.md](appgallery-listing-zh-CN.md) | 华为 AppGallery 商店介绍词（名称/简介/详情/FAQ/审核备注） |
| [privacy-policy-zh-CN.md](privacy-policy-zh-CN.md) | 隐私政策（Markdown 源稿） |
| [site/privacy-policy-zh-CN.html](site/privacy-policy-zh-CN.html) | 隐私政策（GitHub Pages 页面，发布后通过 `https://xhenr.github.io/arkdesk/privacy-policy-zh-CN` 访问） |
| [compliance-checklist.md](compliance-checklist.md) | 上架前合规清单（AGPL / 备案 / 软著等） |

## 上架前必须完成的发布动作

1. **创建源码仓库** `github.com/xhenr/arkdesk`（AGPL-3.0 义务），包含 Rust 核心 + HAR + ArkTS 全部源码与 LICENCE 文件；
2. **发布隐私政策页面**：将 `site/` 目录作为 GitHub Pages 站点（仓库名 `arkdesk` 时默认域名为 `xhenr.github.io/arkdesk`），或托管到自有域名；
3. 替换文中的占位邮箱 `support@xhenr.cloud` 为实际可收信邮箱；
4. 应用内"设置 → 关于"的隐私声明与源码链接已指向 `xhenr.github.io/arkdesk`（见 `SettingsTab.ets`），与上述域名保持一致。
