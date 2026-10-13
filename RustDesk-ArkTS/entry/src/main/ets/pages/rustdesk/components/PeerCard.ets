import { PeerRecord, PeerViewSource } from '../RustDeskDirectoryTypes';
import { peerDisplaySubtitle, peerDisplayTitle } from '../RustDeskPeerDirectoryModel';

export interface PeerCardProps {
  peer: PeerRecord;
  viewSource: PeerViewSource;
  compact: boolean;
  cardWidth: number;
  transferActive: boolean;
  onSetFavorite: (peerId: string, favorite: boolean) => void;
  onRemoveRecent: (peerId: string) => void;
  onRemoveLan: (peerId: string) => void;
  onConnectRemote: (peerId: string) => void;
  onViewOnly: (peerId: string) => void;
  onViewCamera: (peerId: string) => void;
  onOpenTransfer: (peerId: string) => void;
}

@ComponentV2
export struct PeerCard {
  @Param peer: PeerRecord = new PeerRecord();
  @Param viewSource: PeerViewSource = 'recent';
  @Param compact: boolean = false;
  @Param cardWidth: number = 0;
  @Param transferActive: boolean = false;
  @Local actionsExpanded: boolean = false;
  @Event onSetFavorite: (peerId: string, favorite: boolean) => void = (_peerId: string, _favorite: boolean) => {};
  @Event onRemoveRecent: (peerId: string) => void = (_peerId: string) => {};
  @Event onRemoveLan: (peerId: string) => void = (_peerId: string) => {};
  @Event onConnectRemote: (peerId: string) => void = (_peerId: string) => {};
  @Event onViewOnly: (peerId: string) => void = (_peerId: string) => {};
  @Event onViewCamera: (peerId: string) => void = (_peerId: string) => {};
  @Event onOpenTransfer: (peerId: string) => void = (_peerId: string) => {};

  private displayName(): string {
    return peerDisplayTitle(this.peer);
  }

  private identityDetail(): string {
    return peerDisplaySubtitle(this.peer);
  }

  private connectionTarget(): string {
    return this.peer.id.trim();
  }

  private avatarInitial(): string {
    const name = this.displayName().trim();
    if (name.length === 0) {
      return '?';
    }
    return name.substring(0, 1).toUpperCase();
  }

  private toggleFavorite(): void {
    this.onSetFavorite(this.peer.id, !this.peer.favorite);
  }

  private canRemoveFromCurrentView(): boolean {
    return this.viewSource === 'recent' || this.viewSource === 'lan';
  }

  private removeFromCurrentView(): void {
    if (this.viewSource === 'lan') {
      this.onRemoveLan(this.peer.id);
    } else if (this.viewSource === 'recent') {
      this.onRemoveRecent(this.peer.id);
    }
  }

  private hasExpandedActions(): boolean {
    return this.peer.favorite || this.canRemoveFromCurrentView() || this.transferActive;
  }

  private toggleActions(): void {
    if (!this.hasExpandedActions()) {
      return;
    }
    this.actionsExpanded = !this.actionsExpanded;
  }

  @Builder
  private ActionButton(label: string, symbol: Resource, danger: boolean, onClick: () => void) {
    Column({ space: 5 }) {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        SymbolGlyph(symbol)
          .fontSize(18)
          .fontColor([danger ? $r('app.color.error') : $r('app.color.text_secondary')]);
      }
      .width(40)
      .height(40)
      .padding(0)
      .borderRadius(12)
      .backgroundColor($r('app.color.surface_secondary'))
      .onClick(() => onClick());

      Text(label)
        .fontSize(10)
        .fontColor($r('app.color.text_tertiary'));
    }
    .layoutWeight(1);
  }

  @Builder
  private ExpandedActions() {
    Row({ space: 8 }) {
      this.ActionButton(
        this.peer.favorite ? '取消收藏' : '收藏',
        this.peer.favorite ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'),
        false,
        (): void => this.toggleFavorite(),
      );
      if (this.canRemoveFromCurrentView()) {
        this.ActionButton(
          '移除',
          $r('sys.symbol.trash'),
          true,
          (): void => this.removeFromCurrentView(),
        );
      }
    }
    .width('100%');
  }

  build() {
    Column({ space: 10 }) {
      // ── 主行：头像 + 名称 + 在线点 + 主操作 ──
      Row({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          Text(this.avatarInitial())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_inverse'));
          if (this.peer.online) {
            Circle({ width: 10, height: 10 })
              .fill($r('app.color.success'))
              .translate({ x: 14, y: 14 })
          }
        }
        .width(42)
        .height(42)
        .borderRadius(12)
        .backgroundColor(this.peer.online
          ? $r('app.color.brand_primary')
          : $r('app.color.disabled_text'));

        Column({ space: 3 }) {
          Text(this.displayName())
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text(`${this.connectionTarget()} · ${this.identityDetail()}`)
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .onClick(() => this.onConnectRemote(this.connectionTarget()));

        if (this.hasExpandedActions()) {
          SymbolGlyph($r('sys.symbol.chevron_down'))
            .fontSize(14)
            .fontColor([$r('app.color.text_tertiary')])
            .rotate({ angle: this.actionsExpanded ? 180 : 0 })
            .onClick(() => this.toggleActions());
        } else {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(14)
            .fontColor([$r('app.color.text_tertiary')]);
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      // ── 快捷会话操作（始终可见）──
      Row({ space: 8 }) {
        this.QuickAction('远控', $r('sys.symbol.display'), false,
          (): void => this.onConnectRemote(this.connectionTarget()));
        this.QuickAction('观看', $r('sys.symbol.eye'), false,
          (): void => this.onViewOnly(this.connectionTarget()));
        this.QuickAction('相机', $r('sys.symbol.video'), false,
          (): void => this.onViewCamera(this.connectionTarget()));
        this.QuickAction(
          this.transferActive ? '传输中' : '文件',
          $r('sys.symbol.folder'),
          this.transferActive,
          (): void => this.onOpenTransfer(this.connectionTarget()),
        );
      }
      .width('100%');

      // ── 展开区：收藏/移除 ──
      if (this.actionsExpanded) {
        this.ExpandedActions();
      }
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
    });
  }

  @Builder
  private QuickAction(label: string, symbol: Resource, accent: boolean, onClick: () => void) {
    Column({ space: 4 }) {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        SymbolGlyph(symbol)
          .fontSize(16)
          .fontColor([accent ? $r('app.color.brand_primary') : $r('app.color.text_secondary')]);
      }
      .width(40)
      .height(36)
      .padding(0)
      .borderRadius(10)
      .backgroundColor(accent ? $r('app.color.brand_primary_soft') : $r('app.color.surface_secondary'))
      .onClick(() => onClick());

      Text(label)
        .fontSize(10)
        .fontColor(accent ? $r('app.color.brand_primary') : $r('app.color.text_tertiary'));
    }
    .layoutWeight(1);
  }
}
