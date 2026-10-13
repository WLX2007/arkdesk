import { LuminousSelectionItem } from './SelectionItem';

@ComponentV2
export struct LuminousSegmentedControl {
  @Param items: LuminousSelectionItem[] = [];
  @Param selectedIndex: number = 0;
  @Param controlWidth: number = 280;
  @Param controlHeight: number = 48;
  @Param motionEnabled: boolean = true;
  @Event onChange: (index: number) => void = (_index: number) => {};

  build(): void {
    Row({ space: 4 }) {
      ForEach(this.items, (item: LuminousSelectionItem, index: number) => {
        Column({ space: 2 }) {
          Text(item.label)
            .fontSize(14)
            .fontWeight(this.selectedIndex === index ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selectedIndex === index
              ? $r('app.color.text_inverse')
              : $r('app.color.text_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          if (item.description !== '') {
            Text(item.description)
              .fontSize(10)
              .fontColor(this.selectedIndex === index
                ? 'rgba(255,255,255,0.8)'
                : $r('app.color.text_tertiary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .borderRadius(this.controlHeight / 2 - 2)
        .backgroundColor(this.selectedIndex === index
          ? $r('app.color.brand_primary')
          : Color.Transparent)
        .opacity(item.isEnabled ? 1 : 0.4)
        .onClick(() => {
          if (item.isEnabled && index !== this.selectedIndex) {
            this.onChange(index);
          }
        });
      }, (item: LuminousSelectionItem) => item.key);
    }
    .width(this.controlWidth > 0 ? this.controlWidth : '100%')
    .height(this.controlHeight)
    .padding(3)
    .borderRadius(this.controlHeight / 2)
    .backgroundColor($r('app.color.surface_secondary'));
  }
}
