@ComponentV2
export struct LuminousSearchField {
  @Param value: string = '';
  @Param placeholder: ResourceStr = '';
  @Param fieldWidth: number = 240;
  @Param fieldHeight: number = 44;
  @Param motionEnabled: boolean = true;
  @Event onChange: (value: string) => void = (_value: string) => {};

  @Local private text: string = '';

  aboutToAppear(): void {
    this.text = this.value;
  }

  @Monitor('value')
  private onValueChanged(): void {
    if (this.text !== this.value) {
      this.text = this.value;
    }
  }

  build(): void {
    Search({ value: this.text, placeholder: this.placeholder })
      .width(this.fieldWidth)
      .height(this.fieldHeight)
      .borderRadius(this.fieldHeight / 2)
      .backgroundColor($r('app.color.field_background'))
      .onChange((value: string) => {
        this.text = value;
        this.onChange(value);
      });
  }
}
