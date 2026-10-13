/**
 * Flat stand-in for the neumorphic LuminousSurface container.
 * depth > 0: raised card; depth < 0: inset (pressed); depth ~0: flat.
 * Supports a trailing builder closure as its content, plus optional
 * contentAlignment param observed in the app.
 */
@ComponentV2
export struct LuminousSurface {
  @Param depth: number = 1;
  @Param surfaceWidth: number = 0;
  @Param surfaceHeight: number = 0;
  @Param cornerRadius: number = 16;
  @Param motionEnabled: boolean = true;
  @Param contentAlignment: Alignment = Alignment.Center;
  @BuilderParam content: () => void = this.Empty;

  @Builder
  private Empty() {
  }

  private surfaceBackground(): Resource {
    if (this.depth < 0) {
      return $r('sys.color.ohos_id_color_button_normal');
    }
    return $r('sys.color.ohos_id_color_card_bg');
  }

  build(): void {
    Column() {
      Column() {
        this.content();
      }
      .width('100%')
      .height('100%')
      .alignItems(this.contentAlignment === Alignment.TopStart
        ? HorizontalAlign.Start
        : HorizontalAlign.Center)
      .justifyContent(this.contentAlignment === Alignment.TopStart
        ? FlexAlign.Start
        : FlexAlign.Center)
    }
    .width(this.surfaceWidth > 0 ? this.surfaceWidth : '100%')
    .height(this.surfaceHeight > 0 ? this.surfaceHeight : '100%')
    .borderRadius(this.cornerRadius)
    .backgroundColor(this.surfaceBackground())
    .border({
      width: 0.8,
      color: this.depth < 0
        ? 'rgba(0,0,0,0.08)'
        : 'rgba(255,255,255,0.6)',
    })
    .clip(true);
  }
}
