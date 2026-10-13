@ComponentV2
export struct LuminousSwitch {
  @Param label: ResourceStr = '';
  @Param description: ResourceStr = '';
  @Param isOn: boolean = false;
  @Param rowWidth: number = 280;
  @Param isEnabled: boolean = true;
  @Param motionEnabled: boolean = true;
  @Event onChange: (enabled: boolean) => void = (_enabled: boolean) => {};

  @Local private on: boolean = false;

  aboutToAppear(): void {
    this.on = this.isOn;
  }

  @Monitor('isOn')
  private onIsOnChanged(): void {
    if (this.on !== this.isOn) {
      this.on = this.isOn;
    }
  }

  build(): void {
    Row({ space: 12 }) {
      Column({ space: 2 }) {
        Text(this.label)
          .fontSize(15)
          .fontColor($r('sys.color.text_primary'));
        if (this.description !== '') {
          Text(this.description)
            .fontSize(12)
            .fontColor($r('sys.color.text_secondary'));
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.on })
        .enabled(this.isEnabled)
        .onChange((isOn: boolean) => {
          this.on = isOn;
          this.onChange(isOn);
        });
    }
    .width(this.rowWidth > 0 ? this.rowWidth : '100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .borderRadius(16)
    .backgroundColor($r('sys.color.surface'))
    .alignItems(VerticalAlign.Center);
  }
}
