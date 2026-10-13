@ComponentV2
export struct LuminousSlider {
  @Param label: ResourceStr = '';
  @Param value: number = 0;
  @Param minimum: number = 0;
  @Param maximum: number = 100;
  @Param step: number = 1;
  @Param sliderWidth: number = 240;
  @Param motionEnabled: boolean = true;
  @Event onChange: (value: number, mode: SliderChangeMode) => void = (_value: number, _mode: SliderChangeMode) => {};

  @Local private current: number = 0;

  aboutToAppear(): void {
    this.current = this.value;
  }

  @Monitor('value')
  private onValueChanged(): void {
    if (this.current !== this.value) {
      this.current = this.value;
    }
  }

  build(): void {
    Column({ space: 6 }) {
      Row() {
        Text(this.label)
          .fontSize(14)
          .fontColor($r('sys.color.text_primary'));
        Text(`${Math.round(this.current)}`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.text_primary'));
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Slider({
        value: this.current,
        min: this.minimum,
        max: this.maximum,
        step: this.step,
        style: SliderStyle.OutSet,
      })
        .width(this.sliderWidth > 0 ? this.sliderWidth : '100%')
        .onChange((value: number, mode: SliderChangeMode) => {
          this.current = value;
          if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
            this.onChange(value, mode);
          }
        });
    }
    .width(this.sliderWidth > 0 ? this.sliderWidth : '100%');
  }
}
