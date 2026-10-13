import { ControlledHostState } from '../../../services/controlled/ControlledHostTypes';

export interface ViewedHostCardProps {
  state: ControlledHostState;
  surfaceWidth: number;
  onStart: () => void;
  onStop: () => void;
  onAccept: (requestId: string, peerId: string) => void;
  onReject: (requestId: string, peerId: string) => void;
  onRefreshPassword: () => void;
}

@ComponentV2
export struct ViewedHostCard {
  @Param state: ControlledHostState = new ControlledHostState();
  @Param surfaceWidth: number = 520;
  @Local passwordVisible: boolean = false;
  @Local passwordDisplayText: string = '等待生成';
  @Local passwordRevealGeneration: number = 0;
  @Event onStart: () => void = () => {};
  @Event onStop: () => void = () => {};
  @Event onAccept: (requestId: string, peerId: string) => void = (_requestId: string, _peerId: string) => {};
  @Event onReject: (requestId: string, peerId: string) => void = (_requestId: string, _peerId: string) => {};
  @Event onRefreshPassword: () => void = () => {};

  aboutToAppear(): void {
    this.hideTemporaryPassword();
  }

  aboutToDisappear(): void {
    this.hideTemporaryPassword();
  }

  @Monitor('state.temporaryPassword')
  private onTemporaryPasswordChanged(_monitor: IMonitor): void {
    this.hideTemporaryPassword();
  }

  // ── 状态判定 ───────────────────────────────

  private running(): boolean {
    return this.state.phase === 'starting' || this.state.phase === 'ready' || this.state.phase === 'incoming' ||
      this.state.phase === 'active' || this.state.phase === 'stopping';
  }

  private incoming(): boolean {
    return this.state.incoming !== undefined && !this.state.incomingResolving;
  }

  private statusActive(): boolean {
    return this.state.phase === 'ready' || this.state.phase === 'active';
  }

  private statusSymbol(): Resource {
    if (this.state.phase === 'failed') {
      return $r('sys.symbol.exclamationmark_triangle');
    }
    if (this.incoming()) {
      return $r('sys.symbol.bell');
    }
    if (this.state.phase === 'incoming') {
      return $r('sys.symbol.bell');
    }
    if (this.state.phase === 'active') {
      return $r('sys.symbol.display');
    }
    if (this.statusActive()) {
      return $r('sys.symbol.checkmark_shield');
    }
    if (this.running()) {
      return $r('sys.symbol.hourglass');
    }
    return $r('sys.symbol.power');
  }

  private statusTone(): ResourceColor {
    if (this.state.phase === 'failed') {
      return $r('app.color.error');
    }
    if (this.incoming()) {
      return $r('app.color.warning');
    }
    if (this.statusActive()) {
      return $r('app.color.success');
    }
    return $r('app.color.text_secondary');
  }

  private statusToneSoft(): ResourceColor {
    if (this.state.phase === 'failed') {
      return $r('app.color.error_soft');
    }
    if (this.incoming()) {
      return $r('app.color.warning_soft');
    }
    if (this.statusActive()) {
      return $r('app.color.success_soft');
    }
    return $r('app.color.surface_secondary');
  }

  private statusTitle(): string {
    if (this.state.phase === 'failed') {
      return '授控服务启动失败';
    }
    if (this.incoming()) {
      return '有设备请求观看本机';
    }
    if (this.state.phase === 'starting') {
      return '正在等待系统录屏确认';
    }
    if (this.state.phase === 'active') {
      return this.state.activePeerName.length > 0
        ? `正在向 ${this.state.activePeerName} 共享`
        : '正在共享本机屏幕';
    }
    if (this.state.phase === 'incoming') {
      return '有设备正在等待授权';
    }
    if (this.state.phase === 'ready') {
      return '授控服务已就绪';
    }
    if (this.state.phase === 'stopping') {
      return '正在停止授控服务';
    }
    return '授控服务未启用';
  }

  private statusDetail(): string {
    if (this.state.phase === 'failed') {
      return this.state.lastError.length > 0 ? this.state.lastError : '请检查系统录屏与音频权限后重试';
    }
    if (this.incoming()) {
      return '同意后远端可免密观看本机屏幕，可随时停止';
    }
    if (this.state.phase === 'active') {
      return '屏幕与设备内音频正在被远端观看';
    }
    if (this.state.phase === 'incoming') {
      return '等待本机授权，或由远端输入密码接入';
    }
    if (this.state.phase === 'ready') {
      return this.state.captureActive
        ? '等待远端设备使用下方 ID 与密码接入'
        : '服务进程已启动，正在等待采集权限';
    }
    if (this.state.phase === 'starting') {
      return '请在系统弹窗中允许屏幕录制';
    }
    return '启用后，本机可被其他设备远程观看';
  }

  private backgroundRunning(): boolean {
    return this.running() && this.state.runningInBackground;
  }

  // ── 密码处理 ───────────────────────────────

  private hideTemporaryPassword(): void {
    this.passwordRevealGeneration += 1;
    this.passwordVisible = false;
    this.passwordDisplayText = this.state.temporaryPassword.length > 0 ? '••••••' : '等待生成';
  }

  private revealTemporaryPassword(): void {
    if (this.state.temporaryPassword.length === 0) {
      return;
    }
    this.passwordRevealGeneration += 1;
    const generation: number = this.passwordRevealGeneration;
    this.passwordVisible = true;
    this.passwordDisplayText = this.state.temporaryPassword;
    setTimeout((): void => {
      if (generation === this.passwordRevealGeneration) {
        this.hideTemporaryPassword();
      }
    }, 15000);
  }

  // ── 通用构件 ───────────────────────────────

  @Builder
  private CardTitle(title: ResourceStr, subtitle: ResourceStr) {
    Column({ space: 2 }) {
      Text(title)
        .width('100%')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'));
      Text(subtitle)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor($r('app.color.text_tertiary'));
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private IdentityRow(label: ResourceStr, value: ResourceStr, monospace: boolean) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'));
      Blank();
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontFamily(monospace ? 'monospace' : '')
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 11, bottom: 11 })
    .borderRadius(12)
    .backgroundColor($r('app.color.surface_secondary'))
    .alignItems(VerticalAlign.Center);
  }

  // ── ① 服务状态卡 ───────────────────────────

  @Builder
  private StatusCard() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          SymbolGlyph(this.statusSymbol())
            .fontSize(22)
            .fontColor([this.statusTone()]);
        }
        .width(46)
        .height(46)
        .borderRadius(14)
        .backgroundColor(this.statusToneSoft());

        Column({ space: 3 }) {
          Text(this.statusTitle())
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text(this.statusDetail())
            .fontSize(12)
            .lineHeight(17)
            .fontColor($r('app.color.text_tertiary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      if (this.backgroundRunning()) {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.arrow_clockwise'))
            .fontSize(14)
            .fontColor([$r('app.color.brand_primary')]);
          Text('已开启后台共享，退到后台仍会继续')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'));
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .borderRadius(10)
        .backgroundColor($r('app.color.brand_primary_soft'))
        .alignItems(VerticalAlign.Center);
      }

      if (this.state.phase === 'failed' && this.state.lastError.length > 0) {
        Text(this.state.lastError)
          .width('100%')
          .fontSize(12)
          .lineHeight(17)
          .fontColor($r('app.color.error'));
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
  }

  // ── ② 接入请求卡（有待授权请求时置顶）──────

  @Builder
  private IncomingCard() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          Text(this.incomingInitial())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_inverse'));
        }
        .width(42)
        .height(42)
        .borderRadius(12)
        .backgroundColor(this.state.incoming !== undefined && this.state.incoming.authorized
          ? $r('app.color.success')
          : $r('app.color.brand_primary'));

        Column({ space: 3 }) {
          Text(this.incomingName())
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text(`设备 ID ${this.incomingPeerId()} 请求观看本机`)
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      Row({ space: 10 }) {
        Button('拒绝')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.error'))
          .backgroundColor($r('app.color.error_soft'))
          .borderRadius(12)
          .onClick(() => {
            if (this.state.incoming !== undefined) {
              this.onReject(this.state.incoming.requestId, this.state.incoming.peerId);
            }
          });

        Button(this.state.incoming !== undefined && this.state.incoming.authorized ? '同意并连接' : '同意观看')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_inverse'))
          .backgroundColor($r('app.color.success'))
          .borderRadius(12)
          .onClick(() => {
            if (this.state.incoming !== undefined) {
              this.onAccept(this.state.incoming.requestId, this.state.incoming.peerId);
            }
          });
      }
      .width('100%');
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
  }

  private incomingName(): string {
    if (this.state.incoming === undefined) {
      return '';
    }
    return this.state.incoming.peerName.length > 0 ? this.state.incoming.peerName : this.state.incoming.peerId;
  }

  private incomingPeerId(): string {
    if (this.state.incoming === undefined) {
      return '';
    }
    return this.state.incoming.peerId.length > 0 ? this.state.incoming.peerId : '未知';
  }

  private incomingInitial(): string {
    const name = this.incomingName().trim();
    return name.length > 0 ? name.substring(0, 1).toUpperCase() : '?';
  }

  // ── ③ 本机身份卡 ───────────────────────────

  @Builder
  private IdentityCard() {
    Column({ space: 12 }) {
      this.CardTitle('本机身份', '其他设备使用以下 ID 与密码连接本机');

      this.IdentityRow('设备 ID', this.state.myId.length > 0 ? this.state.myId : '正在加载', true);

      Row() {
        Column({ space: 2 }) {
          Text('临时密码')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'));
          Text(this.passwordDisplayText)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontFamily('monospace')
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          SymbolGlyph(this.passwordVisible ? $r('sys.symbol.eye_slash') : $r('sys.symbol.eye'))
            .fontSize(18)
            .fontColor([this.passwordVisible ? $r('app.color.brand_primary') : $r('app.color.text_secondary')]);
        }
        .width(36)
        .height(36)
        .padding(0)
        .borderRadius(10)
        .backgroundColor(this.passwordVisible ? $r('app.color.brand_primary_soft') : Color.Transparent)
        .opacity(this.state.temporaryPassword.length > 0 ? 1 : 0.4)
        .enabled(this.state.temporaryPassword.length > 0)
        .accessibilityText(this.passwordVisible ? '隐藏临时密码' : '显示临时密码')
        .onClick(() => {
          if (this.passwordVisible) {
            this.hideTemporaryPassword();
          } else {
            this.revealTemporaryPassword();
          }
        });

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.arrow_clockwise'))
            .fontSize(18)
            .fontColor([$r('app.color.text_secondary')]);
        }
        .width(36)
        .height(36)
        .padding(0)
        .borderRadius(10)
        .backgroundColor(Color.Transparent)
        .accessibilityText('刷新临时密码')
        .onClick(() => {
          this.hideTemporaryPassword();
          this.onRefreshPassword();
        });
      }
      .width('100%')
      .padding({ left: 14, right: 8, top: 7, bottom: 7 })
      .borderRadius(12)
      .backgroundColor($r('app.color.surface_secondary'))
      .alignItems(VerticalAlign.Center);

      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.info_circle'))
          .fontSize(12)
          .fontColor([$r('app.color.text_tertiary')]);
        Text('密码显示 15 秒后自动隐藏')
          .fontSize(11)
          .fontColor($r('app.color.text_tertiary'));
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);
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
  }

  // ── ④ 服务开关卡 ───────────────────────────

  @Builder
  private ServiceCard() {
    Column({ space: 12 }) {
      if (this.running()) {
        Button('停止授控服务')
          .width('100%')
          .height(52)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.error'))
          .backgroundColor($r('app.color.error_soft'))
          .borderRadius(14)
          .onClick(() => this.onStop());
      } else {
        Button('启动授控服务')
          .width('100%')
          .height(52)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_inverse'))
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(14)
          .onClick(() => this.onStart());
      }
    }
    .width('100%');
  }

  build(): void {
    Column({ space: 16 }) {
      if (this.incoming()) {
        this.IncomingCard();
      }
      this.StatusCard();
      this.IdentityCard();
      this.ServiceCard();
    }
    .width(this.surfaceWidth)
    .alignItems(HorizontalAlign.Center);
  }
}
