import { ControlledHostState } from '../../../services/controlled/ControlledHostTypes';
import { RustDeskLayoutTokens } from '../RustDeskLayoutTokens';
import { ViewedHostCard } from './ViewedHostCard';

export interface ViewedHostPageProps {
  state: ControlledHostState;
  scroller: Scroller;
  titleSpacerHeight: number;
  bottomAvoidInset: number;
  wideLayout: boolean;
  onStart: () => void;
  onStop: () => void;
  onAccept: (requestId: string, peerId: string) => void;
  onReject: (requestId: string, peerId: string) => void;
  onRefreshPassword: () => void;
}

@ComponentV2
export struct ViewedHostPage {
  @Param state: ControlledHostState = new ControlledHostState();
  @Param scroller: Scroller = new Scroller();
  @Param titleSpacerHeight: number = 56;
  @Param bottomAvoidInset: number = 0;
  @Param wideLayout: boolean = false;
  @Local viewportWidth: number = 390;
  @Event onStart: () => void = () => {};
  @Event onStop: () => void = () => {};
  @Event onAccept: (requestId: string, peerId: string) => void = (_requestId: string, _peerId: string) => {};
  @Event onReject: (requestId: string, peerId: string) => void = (_requestId: string, _peerId: string) => {};
  @Event onRefreshPassword: () => void = () => {};

  private contentWidth(): number {
    return Math.max(280, Math.min(this.viewportWidth - 40, 560));
  }

  private isWideAnchor(): boolean {
    return RustDeskLayoutTokens.useWideContentAnchor(this.viewportWidth, this.wideLayout);
  }

  build(): void {
    Column() {
      Blank()
        .width('100%')
        .height(this.titleSpacerHeight)
        .flexShrink(0);

      List({ scroller: this.scroller }) {
        ListItem() {
          Column({ space: 16 }) {
            ViewedHostCard({
              state: this.state,
              surfaceWidth: this.contentWidth(),
              onStart: () => this.onStart(),
              onStop: () => this.onStop(),
              onAccept: (requestId: string, peerId: string) => this.onAccept(requestId, peerId),
              onReject: (requestId: string, peerId: string) => this.onReject(requestId, peerId),
              onRefreshPassword: () => this.onRefreshPassword(),
            });
          }
          .width('100%')
          .padding({
            top: RustDeskLayoutTokens.PAGE_CONTENT_TOP_PADDING,
            bottom: (this.wideLayout ? 52 : 132) + this.bottomAvoidInset,
          })
          .alignItems(this.isWideAnchor() ? HorizontalAlign.Start : HorizontalAlign.Center);
        }
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true });
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.background'))
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      const width = Number(newArea.width);
      if (width > 0) {
        this.viewportWidth = width;
      }
    });
  }
}
