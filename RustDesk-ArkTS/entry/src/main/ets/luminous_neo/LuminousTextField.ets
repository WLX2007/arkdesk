@ComponentV2
export struct LuminousTextField {
  @Param value: string = '';
  @Param placeholder: ResourceStr = '';
  @Param fieldWidth: number = 240;
  @Param fieldHeight: number = 48;
  @Param inputType: InputType = InputType.Normal;
  @Param maxLength: number = 0;
  @Param isEnabled: boolean = true;
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
    TextInput({ text: this.text, placeholder: this.placeholder })
      .type(this.inputType)
      .maxLength(this.maxLength > 0 ? this.maxLength : 1000)
      .width(this.fieldWidth)
      .height(this.fieldHeight)
      .borderRadius(this.fieldHeight / 2)
      .backgroundColor($r('app.color.field_background'))
      .fontSize(15)
      .opacity(this.isEnabled ? 1 : 0.45)
      .enabled(this.isEnabled)
      .onChange((value: string) => {
        this.text = value;
        this.onChange(value);
      });
  }
}
