import { LuminousControlSize, LuminousControlSizeValue, LuminousTone } from './Tokens';

@ComponentV2
export struct LuminousButton {
  @Param label: ResourceStr = '';
  @Param controlWidth: number = 160;
  @Param controlSizeMode: LuminousControlSizeValue = LuminousControlSize.Regular;
  @Param tone: string = LuminousTone.Neutral;
  @Param isEnabled: boolean = true;
  @Param motionEnabled: boolean = true;
  @Event onAction: () => void = () => {};

  private controlHeight(): number {
    return this.controlSizeMode === LuminousControlSize.Compact ? 40 : 48;
  }

  private toneBackground(): Resource {
    if (!this.isEnabled) {
      return $r('sys.color.field_background');
    }
    if (this.tone === LuminousTone.Danger) {
      return $r('sys.color.error');
    }
    if (this.tone === LuminousTone.Accent) {
      return $r('sys.color.brand_primary');
    }
    return $r('sys.color.text_primary');
  }

  build(): void {
    Button(this.label)
      .width(this.controlWidth)
      .height(this.controlHeight())
      .backgroundColor(this.toneBackground())
      .fontColor(Color.White)
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .borderRadius(this.controlHeight() / 2)
      .opacity(this.isEnabled ? 1 : 0.4)
      .enabled(this.isEnabled)
      .onClick(() => {
        if (this.isEnabled) {
          this.onAction();
        }
      });
  }
}
