# store-listing — 上架与合规材料

本目录存放 ArkDesk 应用市场上架所需的文案、隐私政策与合规文档。

## 文件清单

| 文件 | 用途 |
|---|---|
| [appgallery-listing-zh-CN.md](appgallery-listing-zh-CN.md) | 华为 AppGallery 商店介绍词（名称/简介/详情/FAQ/审核备注） |
| [privacy-policy-zh-CN.md](privacy-policy-zh-CN.md) | 隐私政策（Markdown 源稿） |
| [site/privacy-policy-zh-CN.html](site/privacy-policy-zh-CN.html) | 隐私政策（GitHub Pages 页面，发布后通过 `https://wlx2007.github.io/arkdesk/privacy-policy-zh-CN` 访问） |
| [compliance-checklist.md](compliance-checklist.md) | 上架前合规清单（AGPL / 备案 / 软著等） |

## 上架前必须完成的发布动作

1. ~~**创建源码仓库**~~ ✅ 已完成：https://github.com/WLX2007/arkdesk（需补充根目录 AGPL LICENSE 文件）；
2. **发布隐私政策页面**：在仓库开启 GitHub Pages，从 `main` 分支的 `/store-listing/site` 目录发布（Settings → Pages），域名即为 `wlx2007.github.io/arkdesk`；
3. ~~替换占位邮箱~~ ✅ 已使用 wlx20070108@qq.com；
4. 应用内"设置 → 关于"的隐私声明与源码链接已指向实际地址（见 `SettingsTab.ets`）。
