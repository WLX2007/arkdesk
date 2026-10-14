# ArkDesk 上架合规清单

> 生成日期：2026-10-14。按顺序完成；"中国区"指华为应用市场中国大陆区。

## A. 法律义务（AGPL-3.0）

- [ ] **A1. 公开源码**：创建 `github.com/xhenr/arkdesk` 公开仓库，包含：
  - Rust 核心（rustdesk4ohos，含 AGPL LICENCE 全文）；
  - `rustdesk-ohrs` HAR 构建脚本与补丁；
  - ArkTS 应用全部源码（RustDesk-ArkTS）；
  - 根目录 `LICENSE`/`LICENCE` 保留 AGPL-3.0 全文；
  - README 首段声明："基于 RustDesk（AGPL-3.0）修改，本仓库为修改版完整源码"。
- [ ] **A2. 商店简介中披露**：详情页包含源码链接与本声明（文案见 `appgallery-listing-zh-CN.md`）。
- [ ] **A3. 应用内披露**：设置 → 关于 已加入"开源源码（AGPL-3.0）"入口（`SettingsTab.ets`，指向 GitHub 仓库）。
- [ ] **A4. 保留版权声明**：关于页/简介不删除对 RustDesk 原项目的署名。

## B. 商标与不正当竞争

- [ ] **B1.** 应用名使用 ArkDesk（非 RustDesk）✅（bundle `cloud.xhenr.arkdesk`）
- [ ] **B2.** 简介与宣传图明确标注"非官方"声明 ✅（文案已含）
- [ ] **B3.** 商店宣传素材不使用 RustDesk 官方 logo（说明性文字提及可以）

## C. 隐私合规

- [ ] **C1.** 隐私政策已发布至可公开访问的 URL（GitHub Pages 或自有域名）
- [ ] **C2.** 应用内"隐私声明"入口指向**自己**的政策 URL（已改：`SettingsTab.ets` → `xhenr.github.io/arkdesk/privacy-policy-zh-CN`）
- [ ] **C3.** AGC 后台"隐私政策"字段填写同一 URL
- [ ] **C4.** 替换占位邮箱 `support@xhenr.cloud` 为真实邮箱（两处：`privacy-policy-zh-CN.md`、`site/privacy-policy-zh-CN.html`）
- [ ] **C5.** 隐私协议门控（AppGalleryKit privacyManager）✅（`PrivacyConsentService.ets` 已实现）
- [ ] **C6.** 权限用途说明：`READ_PASTEBOARD` 已配 `reason` 字符串 ✅

## D. 中国区行政要求（海外区可跳过）

- [ ] **D1.** 工信部 App 备案（需主体为企业/个人实名，域名完成 ICP 备案后，在 AGC 提交备案信息）
- [ ] **D2.** 软件著作权登记证书（登记 ArkTS 层与修改部分，备注基于 AGPL 开源组件；AGC 上架需提供）
- [ ] **D3.** 开发者账号实名认证（建议企业账号，远控工具类个人账号审核更严）
- [ ] **D4.** 如域名 `xhenr.cloud` 用于落地页/政策，需完成该域名的 ICP 备案

## E. 技术与审核材料

- [ ] **E1.** `INTERCEPT_INPUT_EVENT`（受限 ACL 权限）权限说明视频：手机/平板/2in1 三份 ✅（CI 已随包提交，见 `docs/AGC_API_CI.md`）
- [ ] **E2.** 审核备注说明本应用仅为主控端、无被控/监听能力（文案见 listing 文档第五节）
- [ ] **E3.** 版本号规范：当前 `versionName 0.9.0 / versionCode 9000000`，首次上架建议调整为常规版本号
- [ ] **E4.** EasyTier 跨应用依赖：简介已注明为可选功能；如审核被质疑，提供 EasyTier 应用市场链接或说明为可选增强
- [ ] **E5.** 商店素材：图标（含"非官方"徽章）、截图、各尺寸海报

## F. 上架后持续义务

- [ ] **F1.** 每次发版同步更新公开源码仓库（AGPL 要求源码对应所分发的版本）
- [ ] **F2.** 数据处理方式变化时更新隐私政策并重新征求同意
