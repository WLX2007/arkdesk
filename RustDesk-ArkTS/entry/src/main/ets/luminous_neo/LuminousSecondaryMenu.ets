import { LuminousSelectionItem } from './SelectionItem';

/**
 * Collapsible "main + handle" menu stand-in. Renders as a simple segmented
 * row; the handle expands a vertical list of all items.
 */
@ComponentV2
export struct LuminousSecondaryMenu {
  @Param items: LuminousSelectionItem[] = [];
  @Param selectedIndex: number = 0;
  @Param controlWidth: number = 280;
  @Param mainHeight: number = 48;
  @Param itemHeight: number = 44;
  @Param accessibilityLabel: ResourceStr = '';
  @Param handleAccessibilityLabel: ResourceStr = '';
  @Param isEnabled: boolean = true;
  @Param motionEnabled: boolean = true;
  @Event onChange: (index: number) => void = (_index: number) => {};

  @Local private expanded: boolean = false;

  build(): void {
    Column({ space: 4 }) {
      Row({ space: 4 }) {
        ForEach(this.items, (item: LuminousSelectionItem, index: number) => {
          Text(item.label)
            .fontSize(12)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ left: 10, right: 10 })
            .height('100%')
            .borderRadius(this.mainHeight / 2 - 2)
            .backgroundColor(this.selectedIndex === index
              ? $r('app.color.brand_primary')
              : Color.Transparent)
            .fontColor(this.selectedIndex === index
              ? Color.White
              : $r('app.color.text_primary'))
            .onClick(() => {
              if (this.isEnabled) {
                this.onChange(index);
              }
            });
        }, (item: LuminousSelectionItem) => item.key)

        Text(this.expanded ? '▲' : '▼')
          .fontSize(12)
          .padding(6)
          .accessibilityLevel(this.handleAccessibilityLabel ? 'yes' : 'no')
          .onClick(() => {
            this.expanded = !this.expanded;
          });
      }
      .width(this.controlWidth > 0 ? this.controlWidth : '100%')
      .height(this.mainHeight)
      .padding(3)
      .borderRadius(this.mainHeight / 2)
      .backgroundColor($r('app.color.field_background'))
      .opacity(this.isEnabled ? 1 : 0.5)
      .accessibilityLevel(this.accessibilityLabel ? 'yes' : 'no')

      if (this.expanded) {
        Column({ space: 2 }) {
          ForEach(this.items, (item: LuminousSelectionItem, index: number) => {
            Column({ space: 1 }) {
              Text(item.label)
                .fontSize(13)
                .fontColor($r('app.color.text_primary'));
              if (item.description !== '') {
                Text(item.description)
                  .fontSize(11)
                  .fontColor($r('app.color.text_secondary'));
              }
            }
            .width('100%')
            .height(this.itemHeight)
            .padding({ left: 12, right: 12 })
            .borderRadius(10)
            .backgroundColor(this.selectedIndex === index
              ? $r('app.color.field_background')
              : Color.Transparent)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            .onClick(() => {
              this.expanded = false;
              if (this.isEnabled) {
                this.onChange(index);
              }
            });
          }, (item: LuminousSelectionItem) => item.key);
        }
        .width(this.controlWidth > 0 ? this.controlWidth : '100%')
        .padding(4)
        .borderRadius(12)
        .backgroundColor($r('app.color.surface'));
      }
    }
    .alignItems(HorizontalAlign.Start);
  }
}
