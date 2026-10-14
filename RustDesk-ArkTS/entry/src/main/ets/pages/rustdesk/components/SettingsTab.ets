import { bundleManager, common, OpenLinkOptions } from '@kit.AbilityKit';
import { AccountLoginProvider, AccountState, ServerConfig, SessionDefaults } from '../RustDeskDirectoryTypes';
import { DecoderCapability } from '../RustDeskTypes';
import { RustDeskLayoutTokens } from '../RustDeskLayoutTokens';
import { AccountSettingsCard } from './AccountSettingsCard';
import { BeginnerGuidePage } from './BeginnerGuidePage';
import { ServerSettingsCard } from './ServerSettingsCard';
import { SessionDefaultsCard } from './SessionDefaultsCard';
import { HostSecuritySettingsCard } from './HostSecuritySettingsCard';
import {
  ControlledHostState,
  ControlledPasswordMode,
  ControlledTrustedDevice,
  ControlledTwoFactorState,
} from '../../../services/controlled/ControlledHostTypes';

const RUSTDESK_WEBSITE_URL: string = 'https://rustdesk.com';
const RUSTDESK_PRIVACY_URL: string = 'https://rustdesk.com/privacy.html';

type SettingsSection = 'tutorial' | 'server' | 'account'
  | 'session_input' | 'session_quality' | 'session_security' | 'session_other'
  | 'diagnostics';

export interface SettingsTabProps {
  decoderCapabilities: DecoderCapability[];
  serverConfig: ServerConfig;
  serverValidating: boolean;
  serverSaving: boolean;
  sessionDefaults: SessionDefaults;
  accountState: AccountState;
  accountLoginProviders: AccountLoginProvider[];
  controlledHostState: ControlledHostState;
  controlledTwoFactorState: ControlledTwoFactorState;
  errorText: string;
  scroller: Scroller;
  wideLayout: boolean;
  titleSpacerHeight: number;
  bottomAvoidInset: number;
  tutorialLaunchToken: number;
  onServerConfigChange: (config: ServerConfig) => void;
  onValidateServerConfig: (config: ServerConfig) => void;
  onSaveServerConfig: (config: ServerConfig) => void;
  onSessionDefaultsChange: (defaults: SessionDefaults) => void;
  onAccountLogin: (username: string, password: string) => void;
  onAccountVerify: (code: string) => void;
  onAccountCancelChallenge: () => void;
  onAccountOidcLogin: (provider: string) => void;
  onAccountOidcCancel: () => void;
  onAddressBookSync: () => void;
  onAccountLogout: () => void;
  onControlledRefresh: () => void;
  onControlledPasswordModeChange: (mode: ControlledPasswordMode) => void;
  onControlledSetPermanentPassword: (password: string, confirmation: string) => void;
  onControlledRemovePermanentPassword: () => void;
  onControlledBeginTwoFactor: () => void;
  onControlledVerifyTwoFactor: (code: string) => void;
  onControlledCancelTwoFactor: () => void;
  onControlledDisableTwoFactor: () => void;
  onControlledTrustedDevicesEnabledChange: (enabled: boolean) => void;
  onControlledRemoveTrustedDevice: (device: ControlledTrustedDevice) => void;
  onControlledClearTrustedDevices: () => void;
  onRefresh: () => void;
  onTutorialAutoOpened: () => void;
}

@ComponentV2
export struct SettingsTab {
  @Param decoderCapabilities: DecoderCapability[] = [];
  @Param serverConfig: ServerConfig = new ServerConfig();
  @Param serverValidating: boolean = false;
  @Param serverSaving: boolean = false;
  @Param sessionDefaults: SessionDefaults = new SessionDefaults();
  @Param accountState: AccountState = new AccountState();
  @Param accountLoginProviders: AccountLoginProvider[] = [];
  @Param controlledHostState: ControlledHostState = new ControlledHostState();
  @Param controlledTwoFactorState: ControlledTwoFactorState = new ControlledTwoFactorState();
  @Param errorText: string = '';
  @Param wideLayout: boolean = false;
  @Param titleSpacerHeight: number = 56;
  @Param bottomAvoidInset: number = 0;
  @Param tutorialLaunchToken: number = 0;
  @Local viewportWidth: number = 390;
  @Local sheetViewportHeight: number = 0;
  @Local selectedSection: SettingsSection = 'server';
  @Local settingsSheetVisible: boolean = false;
  @Local appVersionName: string = '--';
  @Local sessionDefaultsDraft: SessionDefaults = new SessionDefaults();
  private draftInitialized: boolean = false;
  @Param scroller: Scroller = new Scroller();
  private sheetScroller: Scroller = new Scroller();
  private handledTutorialLaunchToken: number = 0;
  @Event onServerConfigChange: (config: ServerConfig) => void = (_config: ServerConfig) => {};
  @Event onValidateServerConfig: (config: ServerConfig) => void = (_config: ServerConfig) => {};
  @Event onSaveServerConfig: (config: ServerConfig) => void = (_config: ServerConfig) => {};
  @Event onSessionDefaultsChange: (defaults: SessionDefaults) => void = (_defaults: SessionDefaults) => {};
  @Event onAccountLogin: (username: string, password: string) => void = (_username: string, _password: string) => {};
  @Event onAccountVerify: (code: string) => void = (_code: string) => {};
  @Event onAccountCancelChallenge: () => void = () => {};
  @Event onAccountOidcLogin: (provider: string) => void = (_provider: string) => {};
  @Event onAccountOidcCancel: () => void = () => {};
  @Event onAddressBookSync: () => void = () => {};
  @Event onAccountLogout: () => void = () => {};
  @Event onControlledRefresh: () => void = () => {};
  @Event onControlledPasswordModeChange: (mode: ControlledPasswordMode) => void =
    (_mode: ControlledPasswordMode) => {};
  @Event onControlledSetPermanentPassword: (password: string, confirmation: string) => void =
    (_password: string, _confirmation: string) => {};
  @Event onControlledRemovePermanentPassword: () => void = () => {};
  @Event onControlledBeginTwoFactor: () => void = () => {};
  @Event onControlledVerifyTwoFactor: (code: string) => void = (_code: string) => {};
  @Event onControlledCancelTwoFactor: () => void = () => {};
  @Event onControlledDisableTwoFactor: () => void = () => {};
  @Event onControlledTrustedDevicesEnabledChange: (enabled: boolean) => void = (_enabled: boolean) => {};
  @Event onControlledRemoveTrustedDevice: (device: ControlledTrustedDevice) => void =
    (_device: ControlledTrustedDevice) => {};
  @Event onControlledClearTrustedDevices: () => void = () => {};
  @Event onRefresh: () => void = () => {};
  @Event onTutorialAutoOpened: () => void = () => {};

  aboutToAppear(): void {
    void this.loadAppVersion();
    setTimeout((): void => this.openRequestedTutorialIfNeeded(), 0);
  }

  private async loadAppVersion(): Promise<void> {
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT,
      );
      this.appVersionName = bundleInfo.versionName.trim().length > 0 ? bundleInfo.versionName : '--';
    } catch (_) {
      this.appVersionName = '--';
    }
  }

  @Monitor('tutorialLaunchToken')
  private onTutorialLaunchTokenChanged(_monitor: IMonitor): void {
    this.openRequestedTutorialIfNeeded();
  }

  private openRequestedTutorialIfNeeded(): void {
    if (this.tutorialLaunchToken <= 0 || this.tutorialLaunchToken <= this.handledTutorialLaunchToken) {
      return;
    }
    this.handledTutorialLaunchToken = this.tutorialLaunchToken;
    this.selectSection('tutorial');
    this.onTutorialAutoOpened();
  }

  private openExternalLink(url: string): void {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const options: OpenLinkOptions = {
        appLinkingOnly: false,
        hideFailureTipDialog: true,
      };
      void context.openLink(url, options).catch((): void => this.showOpenLinkFailure());
    } catch (_) {
      this.showOpenLinkFailure();
    }
  }

  private showOpenLinkFailure(): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: $r('app.string.settings_about_open_failed'),
        duration: 3500,
      });
    } catch (_) {
    }
  }

  private hasError(): boolean {
    return this.errorText.trim().length > 0;
  }

  private isWideAnchor(): boolean {
    return RustDeskLayoutTokens.useWideContentAnchor(this.viewportWidth, this.wideLayout);
  }

  private contentWidth(): number {
    return Math.max(280, Math.min(this.viewportWidth - 40, 560));
  }

  private decoderDisplayName(item: DecoderCapability): string {
    if (item.recommendedName.trim().length > 0) {
      return item.recommendedName.trim();
    }
    if (item.hardwareName.trim().length > 0) {
      return item.hardwareName.trim();
    }
    if (item.softwareName.trim().length > 0) {
      return item.softwareName.trim();
    }
    if (item.mime.trim().length > 0) {
      return item.mime.trim();
    }
    return '系统未返回解码器名称';
  }

  private copySessionDefaults(source: SessionDefaults): SessionDefaults {
    const defaults = new SessionDefaults();
    defaults.touchMode = source.touchMode;
    defaults.relativeMouseMode = source.relativeMouseMode;
    defaults.rightClickGesture = source.rightClickGesture;
    defaults.audioEnabled = source.audioEnabled;
    defaults.clipboardEnabled = source.clipboardEnabled;
    defaults.qualityPreset = source.qualityPreset;
    defaults.customQuality = source.customQuality;
    defaults.customFps = source.customFps;
    defaults.preferredCodec = source.preferredCodec;
    defaults.gesturesEnabled = source.gesturesEnabled;
    defaults.toolbarExpanded = source.toolbarExpanded;
    defaults.sessionSharingEnabled = source.sessionSharingEnabled;
    return defaults;
  }

  private updateSessionDefaultsDraft(defaults: SessionDefaults): void {
    const next = this.copySessionDefaults(defaults);
    this.sessionDefaultsDraft = next;
    this.draftInitialized = true;
    this.onSessionDefaultsChange(this.copySessionDefaults(next));
  }

  private selectSection(section: SettingsSection): void {
    if (section === 'session_input'
      || section === 'session_quality'
      || section === 'session_security'
      || section === 'session_other') {
      // 仅在首次进入时从 @Param 播种。@Param 是父组件快照，用户刚改完还未回流时
      // 仍是旧值，每次都重新播种会把刚才的选择覆盖掉。
      if (!this.draftInitialized) {
        this.sessionDefaultsDraft = this.copySessionDefaults(this.sessionDefaults);
        this.draftInitialized = true;
      }
    }
    this.selectedSection = section;
    this.settingsSheetVisible = true;
    setTimeout(() => {
      this.sheetScroller.scrollEdge(Edge.Top);
    }, 0);
  }

  private closeSettingsSheet(): void {
    this.settingsSheetVisible = false;
  }

  private sheetTitle(): ResourceStr {
    if (this.selectedSection === 'tutorial') {
      return $r('app.string.settings_tutorial_title');
    }
    if (this.selectedSection === 'server') {
      return $r('app.string.settings_server_title');
    }
    if (this.selectedSection === 'account') {
      return $r('app.string.settings_account_title');
    }
    if (this.selectedSection === 'session_input') {
      return '输入模式';
    }
    if (this.selectedSection === 'session_quality') {
      return '画质';
    }
    if (this.selectedSection === 'session_security') {
      return '安全';
    }
    if (this.selectedSection === 'session_other') {
      return '其他';
    }
    return '诊断与关于';
  }

  // ── 入口摘要文案 ────────────────────────────

  private serverSummary(): string {
    if (this.serverConfig.mode === 'official') {
      return '官方服务器';
    }
    const idServer = this.serverConfig.idServer.trim();
    return idServer.length > 0 ? idServer : '自定义服务器';
  }

  private serverDetail(): string {
    if (this.serverConfig.mode === 'official') {
      return '由内核自动选择公共节点';
    }
    if (this.serverConfig.remoteReachable) {
      return '地址解析通过';
    }
    if (this.serverConfig.resultState === 'mode-draft') {
      return '待保存并应用';
    }
    return '尚未测试连接';
  }

  private serverTone(): ResourceColor {
    if (this.serverConfig.mode === 'official' || this.serverConfig.remoteReachable) {
      return $r('app.color.success');
    }
    if (this.serverConfig.resultState === 'mode-draft') {
      return $r('app.color.warning');
    }
    return $r('app.color.text_tertiary');
  }

  private accountSummary(): string {
    if (this.accountState.loggedIn) {
      if (this.accountState.displayName.trim().length > 0) {
        return this.accountState.displayName.trim();
      }
      if (this.accountState.name.trim().length > 0) {
        return this.accountState.name.trim();
      }
      return '已登录';
    }
    return '未登录';
  }

  private accountDetail(): string {
    if (this.accountState.syncing) {
      return '正在同步通讯簿…';
    }
    if (this.accountState.busy) {
      return '正在登录…';
    }
    if (this.accountState.loggedIn) {
      return '通讯簿已同步';
    }
    if (this.accountState.apiServer.trim().length === 0) {
      return '当前未提供账户 API';
    }
    return '登录后可同步通讯簿';
  }

  private accountTone(): ResourceColor {
    if (this.accountState.busy || this.accountState.syncing) {
      return $r('app.color.brand_primary');
    }
    if (this.accountState.loggedIn) {
      return $r('app.color.success');
    }
    return $r('app.color.text_tertiary');
  }

  private inputSummary(): string {
    if (this.sessionDefaults.touchMode) {
      return '触控模式';
    }
    return this.sessionDefaults.relativeMouseMode ? '相对鼠标' : '鼠标模式';
  }

  private qualitySummary(): string {
    if (this.sessionDefaults.qualityPreset === 'best') {
      return '最佳画质';
    }
    if (this.sessionDefaults.qualityPreset === 'low') {
      return '流畅优先';
    }
    if (this.sessionDefaults.qualityPreset === 'custom') {
      return `自定义 · ${this.sessionDefaults.customQuality}% · ${this.sessionDefaults.customFps} FPS`;
    }
    return '均衡画质';
  }

  private qualityDetail(): string {
    const codec = this.sessionDefaults.preferredCodec.trim().toUpperCase();
    if (codec.length > 0 && codec !== 'AUTO') {
      return `首选编码器 ${codec}`;
    }
    return '编码器自动选择';
  }

  private securitySummary(): string {
    if (this.controlledTwoFactorState.enabled) {
      return '双重认证已启用';
    }
    if (this.controlledHostState.permanentPasswordSet) {
      return '固定密码已设置';
    }
    return '仅使用临时密码';
  }

  private securityDetail(): string {
    if (this.controlledTwoFactorState.enabled) {
      return this.controlledTwoFactorState.trustedDevicesEnabled
        ? `受信任设备 ${this.controlledTwoFactorState.trustedDevices.length} 台`
        : '受信任设备未启用';
    }
    return '密码、2FA 与受信任设备';
  }

  private securityTone(): ResourceColor {
    if (this.controlledTwoFactorState.enabled) {
      return $r('app.color.success');
    }
    if (this.controlledHostState.permanentPasswordSet) {
      return $r('app.color.warning');
    }
    return $r('app.color.text_tertiary');
  }

  private otherSummary(): string {
    const enabled: string[] = [];
    if (this.sessionDefaults.audioEnabled) {
      enabled.push('音频');
    }
    if (this.sessionDefaults.clipboardEnabled) {
      enabled.push('剪贴板');
    }
    if (this.sessionDefaults.gesturesEnabled) {
      enabled.push('手势');
    }
    return enabled.length > 0 ? enabled.join(' · ') : '全部关闭';
  }

  private diagnosticSummary(): string {
    if (this.hasError()) {
      return '检测到需要处理的运行日志';
    }
    return `${this.decoderCapabilities.length} 项视频解码能力`;
  }

  private diagnosticTone(): ResourceColor {
    return this.hasError() ? $r('app.color.error') : $r('app.color.text_tertiary');
  }

  // ── 入口卡片 ────────────────────────────────

  @Builder
  private EntryIcon(symbol: Resource, tone: ResourceColor, soft: ResourceColor) {
    Stack({ alignContent: Alignment.Center }) {
      SymbolGlyph(symbol)
        .fontSize(20)
        .fontColor([tone]);
    }
    .width(42)
    .height(42)
    .borderRadius(12)
    .backgroundColor(soft);
  }

  @Builder
  private SettingsEntry(
    section: SettingsSection,
    symbol: Resource,
    title: ResourceStr,
    summary: string,
    detail: string,
    tone: ResourceColor,
    soft: ResourceColor,
    isLast: boolean,
  ) {
    Row({ space: 12 }) {
      this.EntryIcon(symbol, tone, soft);

      Column({ space: 3 }) {
        Row({ space: 8 }) {
          Text(title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Text(summary)
            .fontSize(12)
            .fontColor(tone)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .alignItems(VerticalAlign.Center);

        Text(detail)
          .width('100%')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(14)
        .fontColor([$r('app.color.text_tertiary')]);
    }
    .width('100%')
    .constraintSize({ minHeight: 64 })
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .alignItems(VerticalAlign.Center)
    .border({
      width: { bottom: isLast ? 0 : 0.5 },
      color: $r('app.color.divider'),
    })
    .onClick(() => this.selectSection(section));
  }

  @Builder
  private GroupTitle(title: string) {
    Text(title)
      .width('100%')
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_tertiary'))
      .padding({ left: 4, bottom: 8 });
  }

  @Builder
  private NetworkGroup() {
    Column() {
      this.GroupTitle('连接与账户');

      Column() {
        this.SettingsEntry(
          'server',
          $r('sys.symbol.wifi_router'),
          $r('app.string.settings_server_title'),
          this.serverSummary(),
          this.serverDetail(),
          this.serverTone(),
          $r('app.color.brand_primary_soft'),
          false,
        );
        this.SettingsEntry(
          'account',
          $r('sys.symbol.person_crop_circle_fill'),
          '账户',
          this.accountSummary(),
          this.accountDetail(),
          this.accountTone(),
          $r('app.color.brand_primary_soft'),
          true,
        );
      }
      .width('100%')
      .borderRadius(18)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      })
      .clip(true);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private SessionGroup() {
    Column() {
      this.GroupTitle('远控默认行为');

      Column() {
        this.SettingsEntry(
          'session_input',
          $r('sys.symbol.hand_tap'),
          '输入模式',
          this.inputSummary(),
          '控制方式与右键手势',
          $r('app.color.brand_primary'),
          $r('app.color.brand_primary_soft'),
          false,
        );
        this.SettingsEntry(
          'session_quality',
          $r('sys.symbol.display'),
          '画质',
          this.qualitySummary(),
          this.qualityDetail(),
          $r('app.color.brand_primary'),
          $r('app.color.brand_primary_soft'),
          false,
        );
        this.SettingsEntry(
          'session_other',
          $r('sys.symbol.gearshape'),
          '其他',
          this.otherSummary(),
          '会话能力与工具栏行为',
          $r('app.color.text_secondary'),
          $r('app.color.surface_secondary'),
          true,
        );
      }
      .width('100%')
      .borderRadius(18)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      })
      .clip(true);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private SecurityGroup() {
    Column() {
      this.GroupTitle('安全');

      Column() {
        this.SettingsEntry(
          'session_security',
          $r('sys.symbol.lock_shield'),
          '本机访问安全',
          this.securitySummary(),
          this.securityDetail(),
          this.securityTone(),
          $r('app.color.surface_secondary'),
          true,
        );
      }
      .width('100%')
      .borderRadius(18)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      })
      .clip(true);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private MoreGroup() {
    Column() {
      this.GroupTitle('帮助与诊断');

      Column() {
        this.SettingsEntry(
          'tutorial',
          $r('sys.symbol.book'),
          $r('app.string.settings_tutorial_title'),
          '使用指南',
          '从首次连接到多会话、文件与授控',
          $r('app.color.text_secondary'),
          $r('app.color.surface_secondary'),
          false,
        );
        this.SettingsEntry(
          'diagnostics',
          $r('sys.symbol.stethoscope'),
          '诊断与关于',
          `版本 ${this.appVersionName}`,
          this.diagnosticSummary(),
          this.diagnosticTone(),
          this.hasError() ? $r('app.color.error_soft') : $r('app.color.surface_secondary'),
          true,
        );
      }
      .width('100%')
      .borderRadius(18)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      })
      .clip(true);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private Hub() {
    Column({ space: 20 }) {
      if (this.hasError()) {
        Row({ space: 10 }) {
          SymbolGlyph($r('sys.symbol.exclamationmark_triangle'))
            .fontSize(16)
            .fontColor([$r('app.color.error')]);
          Text(this.errorText)
            .layoutWeight(1)
            .fontSize(12)
            .lineHeight(17)
            .fontColor($r('app.color.error'))
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .width('100%')
        .padding(14)
        .borderRadius(14)
        .backgroundColor($r('app.color.error_soft'))
        .alignItems(VerticalAlign.Top);
      }

      this.NetworkGroup();
      this.SessionGroup();
      this.SecurityGroup();
      this.MoreGroup();
    }
    .width(this.contentWidth())
    .alignItems(HorizontalAlign.Start);
  }

  // ── 诊断页 ──────────────────────────────────

  @Builder
  private SectionTitle(title: string) {
    Text(title)
      .width('100%')
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_tertiary'))
      .padding({ left: 4, bottom: 8 });
  }

  @Builder
  private AboutCard() {
    Column() {
      this.SectionTitle('关于');

      Column() {
        Row({ space: 12 }) {
          Image($r('app.media.arkdesk'))
            .width(46)
            .height(46)
            .borderRadius(12);

          Column({ space: 3 }) {
            Text('ArkDesk')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'));
            Text(`版本 ${this.appVersionName}`)
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'));
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 14, bottom: 14 })
        .alignItems(VerticalAlign.Center);

        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.divider'));

        this.LinkRow($r('app.string.settings_about_website'), true,
          () => this.openExternalLink(RUSTDESK_WEBSITE_URL));
        this.LinkRow($r('app.string.settings_about_privacy'), false,
          () => this.openExternalLink(RUSTDESK_PRIVACY_URL));
      }
      .width('100%')
      .borderRadius(18)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      })
      .clip(true);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private LinkRow(label: ResourceStr, showDivider: boolean, onClick: () => void) {
    Row({ space: 10 }) {
      Text(label)
        .layoutWeight(1)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'));
      Text($r('app.string.settings_about_open'))
        .fontSize(12)
        .fontColor($r('app.color.brand_primary'));
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(14)
        .fontColor([$r('app.color.text_tertiary')]);
    }
    .width('100%')
    .constraintSize({ minHeight: 48 })
    .padding({ left: 14, right: 14 })
    .alignItems(VerticalAlign.Center)
    .border({
      width: { bottom: showDivider ? 0.5 : 0 },
      color: $r('app.color.divider'),
    })
    .onClick(onClick);
  }

  @Builder
  private DecoderTag(item: DecoderCapability) {
    Text(item.hardwareAvailable ? '硬解'
      : (item.softwareAvailable ? '软解' : (item.mimeAvailable ? 'MIME' : '不支持')))
      .fontSize(11)
      .fontWeight(FontWeight.Medium)
      .fontColor(item.hardwareAvailable ? $r('app.color.success')
        : (item.softwareAvailable ? $r('app.color.brand_primary')
          : (item.mimeAvailable ? $r('app.color.warning') : $r('app.color.error'))))
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      .borderRadius(8)
      .backgroundColor(item.hardwareAvailable ? $r('app.color.success_soft')
        : (item.softwareAvailable ? $r('app.color.brand_primary_soft')
          : (item.mimeAvailable ? $r('app.color.warning_soft') : $r('app.color.error_soft'))));
  }

  @Builder
  private DecoderCard() {
    Column() {
      this.SectionTitle('视频解码能力');

      Column() {
        if (this.decoderCapabilities.length === 0) {
          Row({ space: 10 }) {
            LoadingProgress()
              .width(16)
              .height(16)
              .color($r('app.color.brand_primary'));
            Text('正在查询设备能力')
              .fontSize(13)
              .fontColor($r('app.color.text_tertiary'));
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 16, bottom: 16 })
          .alignItems(VerticalAlign.Center);
        } else {
          ForEach(this.decoderCapabilities, (item: DecoderCapability, index: number) => {
            Row({ space: 12 }) {
              Column({ space: 2 }) {
                Text(item.codec)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'));
                Text(this.decoderDisplayName(item))
                  .fontSize(11)
                  .fontColor($r('app.color.text_tertiary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start);

              this.DecoderTag(item);
            }
            .width('100%')
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .alignItems(VerticalAlign.Center)
            .border({
              width: { bottom: index < this.decoderCapabilities.length - 1 ? 0.5 : 0 },
              color: $r('app.color.divider'),
            });
          }, (item: DecoderCapability) => item.codec);
        }
      }
      .width('100%')
      .borderRadius(18)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      })
      .clip(true);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private DiagnosticsPage() {
    Column({ space: 20 }) {
      this.AboutCard();
      this.DecoderCard();

      Button('刷新诊断信息')
        .width('100%')
        .height(48)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.brand_primary'))
        .backgroundColor($r('app.color.brand_primary_soft'))
        .borderRadius(14)
        .onClick(() => this.onRefresh());
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  // ── 弹层内容 ────────────────────────────────

  @Builder
  private SelectedSettingsContent() {
    if (this.selectedSection === 'tutorial') {
      BeginnerGuidePage()
    } else if (this.selectedSection === 'server') {
      ServerSettingsCard({
        showHeader: false,
        config: this.serverConfig,
        validating: this.serverValidating,
        saving: this.serverSaving,
        onConfigChange: (config: ServerConfig) => this.onServerConfigChange(config),
        onValidate: (config: ServerConfig) => this.onValidateServerConfig(config),
        onSave: (config: ServerConfig) => this.onSaveServerConfig(config),
      })
    } else if (this.selectedSection === 'account') {
      AccountSettingsCard({
        showHeader: false,
        accountState: this.accountState,
        loginProviders: this.accountLoginProviders,
        onLogin: (username: string, password: string) => this.onAccountLogin(username, password),
        onVerify: (code: string) => this.onAccountVerify(code),
        onCancelChallenge: () => this.onAccountCancelChallenge(),
        onOidcLogin: (provider: string) => this.onAccountOidcLogin(provider),
        onOidcCancel: () => this.onAccountOidcCancel(),
        onSync: () => this.onAddressBookSync(),
        onLogout: () => this.onAccountLogout(),
      })
    } else if (this.selectedSection === 'session_input') {
      SessionDefaultsCard({
        showHeader: false,
        section: 'input',
        defaults: this.sessionDefaultsDraft,
        onDefaultsChange: (defaults: SessionDefaults) => this.updateSessionDefaultsDraft(defaults),
      })
    } else if (this.selectedSection === 'session_quality') {
      SessionDefaultsCard({
        showHeader: false,
        section: 'quality',
        defaults: this.sessionDefaultsDraft,
        onDefaultsChange: (defaults: SessionDefaults) => this.updateSessionDefaultsDraft(defaults),
      })
    } else if (this.selectedSection === 'session_security') {
      HostSecuritySettingsCard({
        hostState: this.controlledHostState,
        twoFactor: this.controlledTwoFactorState,
        onRefresh: () => this.onControlledRefresh(),
        onPasswordModeChange: (mode: ControlledPasswordMode) => this.onControlledPasswordModeChange(mode),
        onSetPermanentPassword: (password: string, confirmation: string) =>
          this.onControlledSetPermanentPassword(password, confirmation),
        onRemovePermanentPassword: () => this.onControlledRemovePermanentPassword(),
        onBeginTwoFactor: () => this.onControlledBeginTwoFactor(),
        onVerifyTwoFactor: (code: string) => this.onControlledVerifyTwoFactor(code),
        onCancelTwoFactor: () => this.onControlledCancelTwoFactor(),
        onDisableTwoFactor: () => this.onControlledDisableTwoFactor(),
        onTrustedDevicesEnabledChange: (enabled: boolean) =>
          this.onControlledTrustedDevicesEnabledChange(enabled),
        onRemoveTrustedDevice: (device: ControlledTrustedDevice) => this.onControlledRemoveTrustedDevice(device),
        onClearTrustedDevices: () => this.onControlledClearTrustedDevices(),
      })
    } else if (this.selectedSection === 'session_other') {
      SessionDefaultsCard({
        showHeader: false,
        section: 'other',
        defaults: this.sessionDefaultsDraft,
        onDefaultsChange: (defaults: SessionDefaults) => this.updateSessionDefaultsDraft(defaults),
      })
    } else {
      this.DiagnosticsPage()
    }
  }

  @Builder
  private SettingsSheet() {
    Column() {
      Scroll(this.sheetScroller) {
        Column() {
          Row() {
            Column() {
              this.SelectedSettingsContent()
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%')
          .constraintSize({ minHeight: this.sheetViewportHeight })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Top)
          .padding({
            left: $r('app.float.space_16'),
            right: $r('app.float.space_16'),
            top: $r('app.float.space_16'),
            bottom: $r('app.float.space_24'),
          });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center);
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .onAreaChange((_oldArea: Area, newArea: Area) => {
        const height = Number(newArea.height);
        if (height > 0) {
          this.sheetViewportHeight = height;
        }
      });
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'));
  }

  build() {
    Column() {
      Blank()
        .width('100%')
        .height(this.titleSpacerHeight)
        .flexShrink(0);

      List({ scroller: this.scroller }) {
        ListItem() {
          Column() {
            this.Hub();
          }
          .width('100%')
          .padding({
            top: RustDeskLayoutTokens.PAGE_CONTENT_TOP_PADDING,
            bottom: (this.wideLayout ? 52 : 132) + this.bottomAvoidInset,
          })
          .alignItems(this.isWideAnchor() ? HorizontalAlign.Start : HorizontalAlign.Center);
        }
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true });
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.background'))
    .bindSheet($$this.settingsSheetVisible, this.SettingsSheet(), {
      height: SheetSize.LARGE,
      preferType: SheetType.CENTER,
      showClose: true,
      title: { title: this.sheetTitle() },
      dragBar: false,
      backgroundColor: $r('app.color.background'),
      onWillDismiss: (_action: DismissSheetAction) => {
        this.settingsSheetVisible = false;
      },
      shouldDismiss: (_sheetDismiss: SheetDismiss) => {
        this.settingsSheetVisible = false;
      },
    })
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      const width = Number(newArea.width);
      if (width > 0) {
        this.viewportWidth = width;
      }
    });
  }
}
