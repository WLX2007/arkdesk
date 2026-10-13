import { RustDeskRightClickGesture, SessionDefaults } from '../RustDeskDirectoryTypes';

export type SessionDefaultsSection = 'all' | 'input' | 'quality' | 'other';

export interface SessionDefaultsCardProps {
  showHeader: boolean;
  section: SessionDefaultsSection;
  defaults: SessionDefaults;
  onDefaultsChange: (defaults: SessionDefaults) => void;
}

@ComponentV2
export struct SessionDefaultsCard {
  @Param showHeader: boolean = true;
  @Param section: SessionDefaultsSection = 'all';
  @Param defaults: SessionDefaults = new SessionDefaults();
  @Local viewportWidth: number = 390;
  @Local displayedAudioEnabled: boolean = true;
  @Local displayedClipboardEnabled: boolean = true;
  @Local displayedGesturesEnabled: boolean = true;
  @Local displayedToolbarExpanded: boolean = false;
  @Local displayedSessionSharingEnabled: boolean = false;
  // 分段选择需要本地镜像：@Param 对象被父组件整体替换时不保证重渲染，
  // 只依赖 this.defaults 会导致点击后高亮不跟随。
  @Local displayedPointerMode: number = 1;
  @Local displayedRightClickGesture: number = 0;
  @Local displayedQualityPreset: string = 'balanced';
  @Local displayedCodec: string = 'auto';
  @Event onDefaultsChange: (defaults: SessionDefaults) => void = (_defaults: SessionDefaults) => {};

  aboutToAppear(): void {
    this.syncDisplayedStates();
  }

  @Monitor('defaults')
  private onDefaultsChanged(_monitor: IMonitor): void {
    // 只同步「外部改动」：父组件回流的值与我们本地镜像不一致时才覆盖。
    // 用户在本地刚改过的项，此刻 @Param 可能还是旧快照，直接同步会把选择回退。
    if (this.defaults.qualityPreset === this.displayedQualityPreset
      && this.defaults.preferredCodec === this.displayedCodec
      && this.defaults.audioEnabled === this.displayedAudioEnabled
      && this.defaults.clipboardEnabled === this.displayedClipboardEnabled
      && this.defaults.gesturesEnabled === this.displayedGesturesEnabled
      && this.defaults.toolbarExpanded === this.displayedToolbarExpanded
      && this.defaults.sessionSharingEnabled === this.displayedSessionSharingEnabled
      && this.computePointerModeIndex() === this.displayedPointerMode
      && this.computeRightClickGestureIndex() === this.displayedRightClickGesture) {
      return;
    }
    this.syncDisplayedStates();
  }

  private syncDisplayedStates(): void {
    this.displayedAudioEnabled = this.defaults.audioEnabled;
    this.displayedClipboardEnabled = this.defaults.clipboardEnabled;
    this.displayedGesturesEnabled = this.defaults.gesturesEnabled;
    this.displayedToolbarExpanded = this.defaults.toolbarExpanded;
    this.displayedSessionSharingEnabled = this.defaults.sessionSharingEnabled;
    this.displayedPointerMode = this.computePointerModeIndex();
    this.displayedRightClickGesture = this.computeRightClickGestureIndex();
    this.displayedQualityPreset = this.defaults.qualityPreset;
    this.displayedCodec = this.defaults.preferredCodec;
  }

  // 用本地镜像状态构造待提交对象。
  // @Param defaults 是父组件传入的快照，emit 之后父组件重渲染前仍是旧值，
  // 若从它复制会把本次修改丢掉（表现为「勾选不生效」）。
  private buildDraft(): SessionDefaults {
    const next = new SessionDefaults();
    next.touchMode = this.displayedPointerMode === 0;
    next.relativeMouseMode = this.displayedPointerMode === 2;
    next.rightClickGesture = this.displayedRightClickGesture === 0
      ? 'double_tap'
      : (this.displayedRightClickGesture === 1 ? 'two_finger_tap' : 'long_press');
    next.audioEnabled = this.displayedAudioEnabled;
    next.clipboardEnabled = this.displayedClipboardEnabled;
    next.qualityPreset = this.displayedQualityPreset;
    next.customQuality = this.defaults.customQuality;
    next.customFps = this.defaults.customFps;
    next.preferredCodec = this.displayedCodec;
    next.gesturesEnabled = this.displayedGesturesEnabled;
    next.toolbarExpanded = this.displayedToolbarExpanded;
    next.sessionSharingEnabled = this.displayedSessionSharingEnabled;
    return next;
  }

  private emit(next: SessionDefaults): void {
    this.onDefaultsChange(next);
  }

  private updatePointerMode(index: number): void {
    this.displayedPointerMode = index;
    const next = this.buildDraft();
    next.touchMode = index === 0;
    next.relativeMouseMode = index === 2;
    this.emit(next);
  }

  private computePointerModeIndex(): number {
    if (this.defaults.touchMode) {
      return 0;
    }
    return this.defaults.relativeMouseMode ? 2 : 1;
  }

  private pointerModeIndex(): number {
    return this.displayedPointerMode;
  }

  private updateRightClickGesture(index: number): void {
    this.displayedRightClickGesture = index;
    const next = this.buildDraft();
    const gesture: RustDeskRightClickGesture = index === 0
      ? 'double_tap'
      : (index === 1 ? 'two_finger_tap' : 'long_press');
    next.rightClickGesture = gesture;
    this.emit(next);
  }

  private computeRightClickGestureIndex(): number {
    if (this.defaults.rightClickGesture === 'double_tap') {
      return 0;
    }
    return this.defaults.rightClickGesture === 'two_finger_tap' ? 1 : 2;
  }

  private rightClickGestureIndex(): number {
    return this.displayedRightClickGesture;
  }

  private updateAudio(enabled: boolean): void {
    this.displayedAudioEnabled = enabled;
    const next = this.buildDraft();
    next.audioEnabled = enabled;
    this.emit(next);
  }

  private updateClipboard(enabled: boolean): void {
    this.displayedClipboardEnabled = enabled;
    const next = this.buildDraft();
    next.clipboardEnabled = enabled;
    this.emit(next);
  }

  private updateGestures(enabled: boolean): void {
    this.displayedGesturesEnabled = enabled;
    const next = this.buildDraft();
    next.gesturesEnabled = enabled;
    this.emit(next);
  }

  private updateToolbar(enabled: boolean): void {
    this.displayedToolbarExpanded = enabled;
    const next = this.buildDraft();
    next.toolbarExpanded = enabled;
    this.emit(next);
  }

  private updateSessionSharing(enabled: boolean): void {
    this.displayedSessionSharingEnabled = enabled;
    const next = this.buildDraft();
    next.sessionSharingEnabled = enabled;
    this.emit(next);
  }

  private updateQuality(preset: string): void {
    this.displayedQualityPreset = preset;
    const next = this.buildDraft();
    next.qualityPreset = preset;
    this.emit(next);
  }

  private updateCodec(codec: string): void {
    this.displayedCodec = codec;
    const next = this.buildDraft();
    next.preferredCodec = codec;
    this.emit(next);
  }

  private updateCustomQuality(value: number): void {
    this.displayedQualityPreset = 'custom';
    const next = this.buildDraft();
    next.qualityPreset = 'custom';
    next.customQuality = this.clampCustomQuality(value);
    this.emit(next);
  }

  private updateCustomFps(value: number): void {
    this.displayedQualityPreset = 'custom';
    const next = this.buildDraft();
    next.qualityPreset = 'custom';
    next.customFps = this.clampCustomFps(value);
    this.emit(next);
  }

  private clampCustomQuality(value: number): number {
    if (!Number.isFinite(value)) {
      return 50;
    }
    return Math.min(2000, Math.max(10, Math.round(value)));
  }

  private clampCustomFps(value: number): number {
    if (!Number.isFinite(value)) {
      return 30;
    }
    return Math.min(120, Math.max(5, Math.round(value)));
  }

  private qualityIndex(): number {
    if (this.displayedQualityPreset === 'low') {
      return 0;
    }
    if (this.displayedQualityPreset === 'best') {
      return 2;
    }
    if (this.displayedQualityPreset === 'custom') {
      return 3;
    }
    return 1;
  }

  private updateQualityIndex(index: number): void {
    if (index === 0) {
      this.updateQuality('low');
    } else if (index === 2) {
      this.updateQuality('best');
    } else if (index === 3) {
      this.updateQuality('custom');
    } else {
      this.updateQuality('balanced');
    }
  }

  private codecIndex(): number {
    if (this.displayedCodec === 'h265') {
      return 1;
    }
    if (this.displayedCodec === 'h264') {
      return 2;
    }
    if (this.displayedCodec === 'av1') {
      return 3;
    }
    if (this.displayedCodec === 'vp9') {
      return 4;
    }
    if (this.displayedCodec === 'vp8') {
      return 5;
    }
    return 0;
  }

  private updateCodecIndex(index: number): void {
    if (index === 1) {
      this.updateCodec('h265');
    } else if (index === 2) {
      this.updateCodec('h264');
    } else if (index === 3) {
      this.updateCodec('av1');
    } else if (index === 4) {
      this.updateCodec('vp9');
    } else if (index === 5) {
      this.updateCodec('vp8');
    } else {
      this.updateCodec('auto');
    }
  }

  // ── 通用构件 ────────────────────────────────

  @Builder
  private FieldLabel(text: ResourceStr) {
    Text(text)
      .width('100%')
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_secondary'));
  }

  @Builder
  private CardTitle(title: string, subtitle: string) {
    Column({ space: 3 }) {
      Text(title)
        .width('100%')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'));
      if (subtitle.length > 0) {
        Text(subtitle)
          .width('100%')
          .fontSize(12)
          .lineHeight(17)
          .fontColor($r('app.color.text_tertiary'));
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  // ── 分段选择（原生）─────────────────────────

  // 注意：@Builder 的入参是按值捕获的，把 selected 当参数传入不会建立响应式依赖，
  // 切换后高亮不会刷新。因此这里直接读取 @Local 状态来判断选中。
  @Builder
  private PointerSegmentOption(label: string, index: number) {
    Text(label)
      .layoutWeight(1)
      .height(40)
      .fontSize(14)
      .fontWeight(this.displayedPointerMode === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.displayedPointerMode === index
        ? $r('app.color.text_inverse')
        : $r('app.color.text_secondary'))
      .textAlign(TextAlign.Center)
      .borderRadius(11)
      .backgroundColor(this.displayedPointerMode === index
        ? $r('app.color.brand_primary')
        : Color.Transparent)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .onClick(() => this.updatePointerMode(index));
  }

  @Builder
  private PointerSegmentRow() {
    Row({ space: 4 }) {
      this.PointerSegmentOption('触控模式', 0)
      this.PointerSegmentOption('鼠标模式', 1)
      this.PointerSegmentOption('相对鼠标', 2)
    }
    .width('100%')
    .padding(3)
    .borderRadius(14)
    .backgroundColor($r('app.color.surface_secondary'));
  }

  @Builder
  private GestureSegmentOption(label: string, index: number) {
    Text(label)
      .layoutWeight(1)
      .height(40)
      .fontSize(14)
      .fontWeight(this.displayedRightClickGesture === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.displayedRightClickGesture === index
        ? $r('app.color.text_inverse')
        : $r('app.color.text_secondary'))
      .textAlign(TextAlign.Center)
      .borderRadius(11)
      .backgroundColor(this.displayedRightClickGesture === index
        ? $r('app.color.brand_primary')
        : Color.Transparent)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .onClick(() => this.updateRightClickGesture(index));
  }

  @Builder
  private GestureSegmentRow() {
    Row({ space: 4 }) {
      this.GestureSegmentOption('双击', 0)
      this.GestureSegmentOption('双指点击', 1)
      this.GestureSegmentOption('长按', 2)
    }
    .width('100%')
    .padding(3)
    .borderRadius(14)
    .backgroundColor($r('app.color.surface_secondary'));
  }

  @Builder
  private QualitySegmentOption(label: string, index: number) {
    Text(label)
      .layoutWeight(1)
      .height(40)
      .fontSize(14)
      .fontWeight(this.qualityIndex() === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.qualityIndex() === index
        ? $r('app.color.text_inverse')
        : $r('app.color.text_secondary'))
      .textAlign(TextAlign.Center)
      .borderRadius(11)
      .backgroundColor(this.qualityIndex() === index
        ? $r('app.color.brand_primary')
        : Color.Transparent)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .onClick(() => this.updateQualityIndex(index));
  }

  @Builder
  private QualitySegmentRow() {
    Row({ space: 4 }) {
      this.QualitySegmentOption('流畅', 0)
      this.QualitySegmentOption('均衡', 1)
      this.QualitySegmentOption('最佳', 2)
      this.QualitySegmentOption('自定义', 3)
    }
    .width('100%')
    .padding(3)
    .borderRadius(14)
    .backgroundColor($r('app.color.surface_secondary'));
  }

  // ── 开关行（原生，带分隔线）─────────────────

  @Builder
  private ToggleRow(label: ResourceStr, description: string, value: boolean, isLast: boolean,
    onChange: (enabled: boolean) => void) {
    Row({ space: 12 }) {
      Column({ space: 3 }) {
        Text(label)
          .width('100%')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'));
        if (description.length > 0) {
          Text(description)
            .width('100%')
            .fontSize(11)
            .lineHeight(16)
            .fontColor($r('app.color.text_tertiary'));
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Toggle({ type: ToggleType.Switch, isOn: value })
        .selectedColor($r('app.color.brand_primary'))
        .onChange((isOn: boolean) => onChange(isOn));
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .alignItems(VerticalAlign.Center)
    .border({
      width: { bottom: isLast ? 0 : 0.5 },
      color: $r('app.color.divider'),
    });
  }

  // ── 输入模式 ────────────────────────────────

  @Builder
  private InputModeHelpCard(
    modeIndex: number,
    title: string,
    description: string,
    gestures: string,
  ) {
    Column({ space: 4 }) {
      Row() {
        Text(title)
          .layoutWeight(1)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.pointerModeIndex() === modeIndex
            ? $r('app.color.brand_primary')
            : $r('app.color.text_primary'));

        if (this.pointerModeIndex() === modeIndex) {
          Text('当前默认')
            .fontSize(11)
            .fontColor($r('app.color.brand_primary'));
        }
      }
      .width('100%');

      Text(description)
        .width('100%')
        .fontSize(12)
        .lineHeight(17)
        .fontColor($r('app.color.text_secondary'));

      Text(`手势：${gestures}`)
        .width('100%')
        .fontSize(11)
        .lineHeight(16)
        .fontColor($r('app.color.text_tertiary'));
    }
    .width('100%')
    .padding(12)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.pointerModeIndex() === modeIndex
      ? $r('app.color.brand_primary_soft')
      : $r('app.color.surface_secondary'))
    .borderRadius(12);
  }

  @Builder
  private InputSection() {
    Column({ space: 16 }) {
      Column({ space: 12 }) {
        this.FieldLabel($r('app.string.settings_pointer_mode'));
        this.PointerSegmentRow();
      }
      .width('100%')
      .padding(16)
      .borderRadius(18)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      })
      .alignItems(HorizontalAlign.Start);

      Column({ space: 12 }) {
        this.FieldLabel('右键手势');
        this.GestureSegmentRow();
      }
      .width('100%')
      .padding(16)
      .borderRadius(18)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      })
      .alignItems(HorizontalAlign.Start);

      Column({ space: 10 }) {
        this.CardTitle('模式与手势说明', '');
        this.InputModeHelpCard(
          1,
          '鼠标模式',
          '把屏幕当作触控板，通过虚拟光标精确操作远端。',
          '单指移动光标 · 单击左键 · 双击后按住拖动 · 双指缩放画面 · 三指滑动滚轮',
        )
        this.InputModeHelpCard(
          0,
          '触控模式',
          '触点直接对应远端位置，适合窗口、列表和普通桌面操作。',
          '单击左键 · 单指拖动直接拖拽 · 双指缩放画面 · 三指滑动滚轮',
        )
        this.InputModeHelpCard(
          2,
          '相对鼠标',
          '只发送位移增量，适合游戏、3D 软件和需要无限移动的场景。',
          '单指相对移动 · 单击左键 · 双击后按住拖动 · 三指滑动滚轮',
        )
      }
      .width('100%')
      .padding(16)
      .borderRadius(18)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      })
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%');
  }

  // ── 画质 ────────────────────────────────────

  @Builder
  private CodecOption(label: string, index: number) {
    Text(label)
      .layoutWeight(1)
      .height(40)
      .fontSize(14)
      .fontWeight(this.codecIndex() === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.codecIndex() === index
        ? $r('app.color.text_inverse')
        : $r('app.color.text_secondary'))
      .textAlign(TextAlign.Center)
      .borderRadius(11)
      .backgroundColor(this.codecIndex() === index
        ? $r('app.color.brand_primary')
        : $r('app.color.surface_secondary'))
      .onClick((): void => this.updateCodecIndex(index));
  }

  @Builder
  private CodecSelector() {
    Column({ space: 12 }) {
      this.FieldLabel($r('app.string.settings_codec_preference'));

      Row({ space: 6 }) {
        this.CodecOption('自动', 0)
        this.CodecOption('H.265', 1)
        this.CodecOption('H.264', 2)
      }
      .width('100%');

      Row({ space: 6 }) {
        this.CodecOption('AV1', 3)
        this.CodecOption('VP9', 4)
        this.CodecOption('VP8', 5)
      }
      .width('100%');

      Text($r('app.string.settings_codec_hint'))
        .width('100%')
        .fontSize(11)
        .lineHeight(17)
        .fontColor($r('app.color.text_tertiary'));
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor($r('app.color.surface'))
    .shadow({
      radius: 18,
      color: $r('app.color.shadow'),
      offsetX: 0,
      offsetY: 4,
    })
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private QualitySection() {
    Column({ space: 16 }) {
      Column({ space: 12 }) {
        this.FieldLabel($r('app.string.settings_quality_default'));
        this.QualitySegmentRow();
      }
      .width('100%')
      .padding(16)
      .borderRadius(18)
      .backgroundColor($r('app.color.surface'))
      .shadow({
        radius: 18,
        color: $r('app.color.shadow'),
        offsetX: 0,
        offsetY: 4,
      })
      .alignItems(HorizontalAlign.Start);

      if (this.defaults.qualityPreset === 'custom') {
        Column({ space: 12 }) {
          Row() {
            Text($r('app.string.settings_custom_quality'))
              .layoutWeight(1)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'));
            Text(`${this.clampCustomQuality(this.defaults.customQuality)}%`)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.brand_primary'));
          }
          .width('100%');

          Slider({
            value: this.clampCustomQuality(this.defaults.customQuality),
            min: 10,
            max: 2000,
            step: 10,
            style: SliderStyle.OutSet,
          })
            .width('100%')
            .selectedColor($r('app.color.brand_primary'))
            .trackColor($r('app.color.surface_tertiary'))
            .onChange((value: number, _mode: SliderChangeMode): void => {
              this.updateCustomQuality(value);
            });

          Divider()
            .strokeWidth(0.5)
            .color($r('app.color.divider'));

          Row() {
            Text($r('app.string.settings_custom_fps'))
              .layoutWeight(1)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'));
            Text(`${this.clampCustomFps(this.defaults.customFps)} FPS`)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.brand_primary'));
          }
          .width('100%');

          Slider({
            value: this.clampCustomFps(this.defaults.customFps),
            min: 5,
            max: 120,
            step: 1,
            style: SliderStyle.OutSet,
          })
            .width('100%')
            .selectedColor($r('app.color.brand_primary'))
            .trackColor($r('app.color.surface_tertiary'))
            .onChange((value: number, _mode: SliderChangeMode): void => {
              this.updateCustomFps(value);
            });
        }
        .width('100%')
        .padding(16)
        .borderRadius(18)
        .backgroundColor($r('app.color.surface'))
        .shadow({
          radius: 18,
          color: $r('app.color.shadow'),
          offsetX: 0,
          offsetY: 4,
        })
        .alignItems(HorizontalAlign.Start);
      }

      this.CodecSelector();
    }
    .width('100%');
  }

  // ── 其他（会话能力）─────────────────────────

  @Builder
  private OtherSection() {
    Column({ space: 12 }) {
      this.CardTitle('会话能力', '进入远控会话时的默认行为');

      Column() {
        this.ToggleRow('播放远端音频', '', this.displayedAudioEnabled, false,
          (enabled: boolean): void => this.updateAudio(enabled));
        this.ToggleRow('同步剪贴板', '', this.displayedClipboardEnabled, false,
          (enabled: boolean): void => this.updateClipboard(enabled));
        this.ToggleRow('多指画面手势', '双指移动与缩放画面，三指纵向滑动模拟滚轮',
          this.displayedGesturesEnabled, false,
          (enabled: boolean): void => this.updateGestures(enabled));
        this.ToggleRow('默认展开工具栏', '', this.displayedToolbarExpanded, false,
          (enabled: boolean): void => this.updateToolbar(enabled));
        this.ToggleRow(
          $r('app.string.settings_session_sharing'),
          '仅控制本设备作为分享方；接收连接无需开启',
          this.displayedSessionSharingEnabled, true,
          (enabled: boolean): void => this.updateSessionSharing(enabled));
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

  build() {
    Column({ space: 16 }) {
      if (this.section === 'input') {
        this.InputSection();
      } else if (this.section === 'quality') {
        this.QualitySection();
      } else if (this.section === 'other') {
        this.OtherSection();
      } else {
        this.InputSection();
        this.QualitySection();
        this.OtherSection();
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      const width = Number(newArea.width);
      if (width > 0) {
        this.viewportWidth = width;
      }
    });
  }
}
