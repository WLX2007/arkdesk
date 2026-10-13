import {
  LuminousSelectionItem,
} from '../../../luminous_neo/Index';
import { EasyTierInstanceSummary } from '../../../services/EasyTierApiService';
import { DirectorySnapshot, PeerRecord } from '../RustDeskDirectoryTypes';
import { RustDeskLayoutTokens } from '../RustDeskLayoutTokens';
import { peerDisplaySubtitle, peerDisplayTitle } from '../RustDeskPeerDirectoryModel';

export interface ConnectTabProps {
  target: string;
  rememberPassword: boolean;
  scroller: Scroller;
  onTargetChange: (value: string) => void;
  onConnectRemote: () => void;
  onViewOnly: () => void;
  onViewCamera: () => void;
  onOpenTransfer: () => void;
  onDisconnect: () => void;
  canDisconnect: boolean;
  transferActive: boolean;
  easyTierAvailable: boolean;
  easyTierEnabled: boolean;
  easyTierInstances: EasyTierInstanceSummary[];
  easyTierInstanceId: string;
  easyTierBusy: boolean;
  wideLayout: boolean;
  titleSpacerHeight: number;
  bottomAvoidInset: number;
  directorySnapshot: DirectorySnapshot;
  onEasyTierModeChange: (instanceId: string) => void;
}

type ConnectMode = 'control' | 'view_only' | 'camera' | 'files';

const MODE_ORDER: ConnectMode[] = ['control', 'view_only', 'camera', 'files'];

@ComponentV2
export struct ConnectTab {
  @Param target: string = '';
  @Param rememberPassword: boolean = false;
  @Param canDisconnect: boolean = false;
  @Param transferActive: boolean = false;
  @Param easyTierAvailable: boolean = false;
  @Param easyTierEnabled: boolean = false;
  @Param easyTierInstances: EasyTierInstanceSummary[] = [];
  @Param easyTierInstanceId: string = '';
  @Param easyTierBusy: boolean = false;
  @Param wideLayout: boolean = false;
  @Param titleSpacerHeight: number = 56;
  @Param bottomAvoidInset: number = 0;
  @Param directorySnapshot: DirectorySnapshot = new DirectorySnapshot();
  @Param scroller: Scroller = new Scroller();
  @Local viewportWidth: number = 390;
  @Local connectionMode: ConnectMode = 'control';
  @Local easyTierExpanded: boolean = false;
  @Local modeSheetVisible: boolean = false;
  @Event onTargetChange: (value: string) => void = (_value: string) => {};
  @Event onConnectRemote: () => void = () => {};
  @Event onViewOnly: () => void = () => {};
  @Event onViewCamera: () => void = () => {};
  @Event onOpenTransfer: () => void = () => {};
  @Event onDisconnect: () => void = () => {};
  @Event onEasyTierModeChange: (instanceId: string) => void = (_instanceId: string) => {};

  private contentWidth(): number {
    return Math.max(280, Math.min(this.viewportWidth - 40, 560));
  }

  private isWideAnchor(): boolean {
    return RustDeskLayoutTokens.useWideContentAnchor(this.viewportWidth, this.wideLayout);
  }

  private targetReady(): boolean {
    return this.target.trim().length > 0;
  }

  private modeSymbol(mode: ConnectMode): Resource {
    if (mode === 'view_only') {
      return $r('sys.symbol.eye');
    }
    if (mode === 'camera') {
      return $r('sys.symbol.video');
    }
    if (mode === 'files') {
      return $r('sys.symbol.folder');
    }
    return $r('sys.symbol.display');
  }

  private modeLabel(mode: ConnectMode): string {
    if (mode === 'view_only') {
      return '只看屏幕';
    }
    if (mode === 'camera') {
      return '查看相机';
    }
    if (mode === 'files') {
      return '文件传输';
    }
    return '远程控制';
  }

  private modeHint(mode: ConnectMode): string {
    if (mode === 'view_only') {
      return '只观看画面，不发送任何输入';
    }
    if (mode === 'camera') {
      return '查看远端摄像头画面';
    }
    if (mode === 'files') {
      return '在本机与远端之间传输文件';
    }
    return '连接后可触摸、键鼠或触控板操作远端';
  }

  private primaryActionLabel(): string {
    if (this.connectionMode === 'view_only') {
      return '只看屏幕';
    }
    if (this.connectionMode === 'camera') {
      return '查看相机';
    }
    if (this.connectionMode === 'files') {
      return this.transferActive ? '返回文件传输' : '开始文件传输';
    }
    return this.canDisconnect ? '建立新连接' : '开始连接';
  }

  private primaryActionEnabled(): boolean {
    const notBusy = !this.easyTierBusy || !this.easyTierAvailable || !this.easyTierEnabled;
    return notBusy && (this.targetReady() || (this.connectionMode === 'files' && this.transferActive));
  }

  private activatePrimaryAction(): void {
    if (this.connectionMode === 'view_only') {
      this.onViewOnly();
      return;
    }
    if (this.connectionMode === 'camera') {
      this.onViewCamera();
      return;
    }
    if (this.connectionMode === 'files') {
      this.onOpenTransfer();
      return;
    }
    this.onConnectRemote();
  }

  private selectMode(mode: ConnectMode): void {
    this.connectionMode = mode;
  }

  private easyTierSelectedLabel(): string {
    if (!this.easyTierEnabled) {
      return 'RustDesk 直连';
    }
    for (let index = 0; index < this.easyTierInstances.length; index += 1) {
      if (this.easyTierInstances[index].instanceId === this.easyTierInstanceId) {
        const instance = this.easyTierInstances[index];
        return `EasyTier · ${instance.instanceName}`;
      }
    }
    return 'RustDesk 直连';
  }

  private easyTierStateColor(instance: EasyTierInstanceSummary): ResourceColor {
    if (instance.state === 'running') {
      return $r('app.color.success');
    }
    if (instance.state === 'starting') {
      return $r('app.color.warning');
    }
    return $r('app.color.text_tertiary');
  }

  private easyTierOptionLabel(instance: EasyTierInstanceSummary): string {
    let state = '已停止';
    if (instance.state === 'running') {
      state = '运行中';
    } else if (instance.state === 'starting') {
      state = '启动中';
    }
    return instance.peerCount > 0
      ? `${instance.instanceName} · ${state} · ${instance.peerCount} 个对端`
      : `${instance.instanceName} · ${state}`;
  }

  private commitEasyTier(instanceId: string): void {
    this.onEasyTierModeChange(instanceId);
  }

  private recentPreview(): PeerRecord[] {
    const limit = 4;
    const result: PeerRecord[] = [];
    for (let index = 0; index < this.directorySnapshot.recent.length && index < limit; index += 1) {
      result.push(this.directorySnapshot.recent[index]);
    }
    return result;
  }

  private recentPeerName(peer: PeerRecord): string {
    return peerDisplayTitle(peer);
  }

  private recentPeerTarget(peer: PeerRecord): string {
    return peer.id.trim();
  }

  private recentPeerSubtitle(peer: PeerRecord): string {
    return peerDisplaySubtitle(peer);
  }

  private recentPeerStatusColor(peer: PeerRecord): ResourceColor {
    return peer.online ? $r('app.color.success') : $r('app.color.text_tertiary');
  }

  @Builder
  private ModeSheetRow(mode: ConnectMode) {
    Row({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        SymbolGlyph(this.modeSymbol(mode))
          .fontSize(20)
          .fontColor([this.connectionMode === mode
            ? $r('app.color.text_inverse')
            : $r('app.color.text_secondary')]);
      }
      .width(42)
      .height(42)
      .borderRadius(12)
      .backgroundColor(this.connectionMode === mode
        ? $r('app.color.brand_primary')
        : $r('app.color.surface_secondary'));

      Column({ space: 2 }) {
        Text(this.modeLabel(mode))
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'));
        Text(this.modeHint(mode))
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      if (this.connectionMode === mode) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(16)
          .fontColor([$r('app.color.brand_primary')]);
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
    .borderRadius(14)
    .backgroundColor(this.connectionMode === mode
      ? $r('app.color.brand_primary_soft')
      : Color.Transparent)
    .onClick(() => {
      this.selectMode(mode);
      this.modeSheetVisible = false;
    });
  }

  @Builder
  private ConnectionStage() {
    Column({ space: 16 }) {
      // ── 连接卡 ──────────────────────────────
      Column({ space: 14 }) {
        // 连接模式：图标入口 + 底部弹出选择
        Row({ space: 10 }) {
          Button() {
            SymbolGlyph(this.modeSymbol(this.connectionMode))
              .fontSize(20)
              .fontColor([$r('app.color.text_inverse')]);
          }
          .width(46)
          .height(46)
          .borderRadius(14)
          .backgroundColor($r('app.color.brand_primary'))
          .onClick(() => {
            this.modeSheetVisible = true;
          });

          Column({ space: 2 }) {
            Text(this.modeLabel(this.connectionMode))
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'));
            Text('点击图标可切换连接模式')
              .fontSize(11)
              .fontColor($r('app.color.text_tertiary'));
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .onClick(() => {
            this.modeSheetVisible = true;
          });
        }
        .width('100%');

        // ID 输入
        TextInput({ text: this.target, placeholder: '输入设备 ID 或 IP 地址' })
          .width('100%')
          .height(52)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .placeholderColor($r('app.color.text_tertiary'))
          .placeholderFont({ size: 15 })
          .backgroundColor($r('app.color.field_background'))
          .borderRadius(14)
          .border({ width: 1.5, color: $r('app.color.field_border') })
          .onChange((value: string) => this.onTargetChange(value));

        // 主操作
        Button(this.primaryActionLabel())
          .width('100%')
          .height(52)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_inverse'))
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(14)
          .opacity(this.primaryActionEnabled() ? 1 : 0.45)
          .enabled(this.primaryActionEnabled())
          .onClick(() => this.activatePrimaryAction());

        // 断开（会话中）
        if (this.canDisconnect) {
          Button('断开当前会话')
            .width('100%')
            .height(40)
            .fontSize(14)
            .fontColor($r('app.color.error'))
            .backgroundColor($r('app.color.error_soft'))
            .borderRadius(12)
            .onClick(() => this.onDisconnect());
        }
      }
      .width('100%')
      .padding(18)
      .borderRadius(20)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      });

      // ── EasyTier 折叠区（仅可用时）────────────
      if (this.easyTierAvailable) {
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.link'))
              .fontSize(14)
              .fontColor([$r('app.color.text_tertiary')]);
            Text('预组网')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'));
            Blank();
            Text(this.easyTierSelectedLabel())
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'));
            SymbolGlyph(this.easyTierExpanded ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
              .fontSize(12)
              .fontColor([$r('app.color.text_tertiary')]);
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .borderRadius(12)
          .backgroundColor($r('app.color.surface_secondary'))
          .onClick(() => {
            this.easyTierExpanded = !this.easyTierExpanded;
          });

          if (this.easyTierExpanded) {
            Column({ space: 4 }) {
              this.EasyTierOptionRow('', 'RustDesk 直连', '不使用 EasyTier，直接连接远端设备', !this.easyTierEnabled);
              ForEach(this.easyTierInstances, (instance: EasyTierInstanceSummary) => {
                this.EasyTierOptionRow(
                  instance.instanceId,
                  this.easyTierOptionLabel(instance),
                  `使用 EasyTier 实例 ${instance.instanceName}`,
                  this.easyTierEnabled && this.easyTierInstanceId === instance.instanceId,
                );
              }, (instance: EasyTierInstanceSummary) => instance.instanceId);
            }
            .width('100%');
          }
        }
        .width('100%');
      }
    }
    .width(this.contentWidth());
  }

  @Builder
  private EasyTierOptionRow(instanceId: string, label: string, description: string, selected: boolean) {
    Row({ space: 10 }) {
      SymbolGlyph(selected ? $r('sys.symbol.checkmark_circle_fill') : $r('sys.symbol.circle'))
        .fontSize(18)
        .fontColor([selected ? $r('app.color.brand_primary') : $r('app.color.outline')]);
      Column({ space: 2 }) {
        Text(label)
          .fontSize(14)
          .fontColor($r('app.color.text_primary'));
        Text(description)
          .fontSize(11)
          .fontColor($r('app.color.text_tertiary'));
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .borderRadius(12)
    .backgroundColor(selected ? $r('app.color.brand_primary_soft') : Color.Transparent)
    .onClick(() => this.commitEasyTier(instanceId));
  }

  @Builder
  private RecentSection() {
    Column({ space: 12 }) {
      Row() {
        Text('最近连接')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'));
        Blank();
        Text(`${this.directorySnapshot.recent.length}`)
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'));
      }
      .width('100%');

      if (this.recentPreview().length === 0) {
        this.EmptyRecent();
      } else {
        ForEach(this.recentPreview(), (peer: PeerRecord) => {
          this.RecentCard(peer);
        }, (peer: PeerRecord) => `recent-${this.directorySnapshot.revision}-${peer.id}`);
      }
    }
    .width(this.contentWidth());
  }

  @Builder
  private RecentCard(peer: PeerRecord) {
    Row({ space: 12 }) {
      // 在线状态指示
      Stack({ alignContent: Alignment.Center }) {
        Text(this.recentPeerName(peer).substring(0, 1).toUpperCase())
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_inverse'));
      }
      .width(42)
      .height(42)
      .borderRadius(12)
      .backgroundColor(peer.online ? $r('app.color.brand_primary') : $r('app.color.disabled_text'));

      Column({ space: 3 }) {
        Row({ space: 8 }) {
          Text(this.recentPeerName(peer))
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Circle({ width: 6, height: 6 })
            .fill(this.recentPeerStatusColor(peer));
        }
        .alignItems(VerticalAlign.Center);

        Text(`${this.recentPeerTarget(peer)} · ${this.recentPeerSubtitle(peer)}`)
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
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .borderRadius(16)
    .backgroundColor($r('app.color.surface'))
    .shadow({
      radius: 10,
      color: $r('app.color.shadow'),
      offsetX: 0,
      offsetY: 2,
    })
    .onClick(() => this.onTargetChange(this.recentPeerTarget(peer)));
  }

  @Builder
  private EmptyRecent() {
    Row({ space: 14 }) {
      SymbolGlyph($r('sys.symbol.clock'))
        .fontSize(24)
        .fontColor([$r('app.color.text_tertiary')]);
      Column({ space: 3 }) {
        Text('这里还没有设备')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_secondary'));
        Text('首次连接完成后，会在这里保留最近使用的设备')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'));
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(18)
    .borderRadius(16)
    .backgroundColor($r('app.color.surface_secondary'))
    .border({ width: 1, color: $r('app.color.divider') });
  }

  @Builder
  private Workspace() {
    List({ scroller: this.scroller }) {
      ListItem() {
        Column({ space: 28 }) {
          this.ConnectionStage();
          this.RecentSection();
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

  build() {
    Column() {
      Blank()
        .width('100%')
        .height(this.titleSpacerHeight)
        .flexShrink(0);
      this.Workspace();
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.background'))
    .bindSheet($$this.modeSheetVisible, this.ModeSelectionSheet(), {
      height: 340,
      showClose: true,
      title: { title: '选择连接模式' },
      backgroundColor: $r('app.color.surface'),
      onWillDismiss: (action: DismissSheetAction) => {
        this.modeSheetVisible = false;
      },
      preferType: SheetType.BOTTOM,
      dragBar: false,
      shouldDismiss: (sheetDismiss: SheetDismiss) => {
        this.modeSheetVisible = false;
      },
    })
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      const width = Number(newArea.width);
      if (width > 0) {
        this.viewportWidth = width;
      }
    });
  }

  @Builder
  private ModeSelectionSheet() {
    Column({ space: 4 }) {
      ForEach(MODE_ORDER, (mode: ConnectMode) => {
        this.ModeSheetRow(mode);
      }, (mode: ConnectMode) => mode);
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 0, bottom: 8 });
  }
}
