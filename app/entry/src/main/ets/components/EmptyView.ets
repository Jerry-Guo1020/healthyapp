/**
 * 通用空态视图
 */
@Component
export struct EmptyView {
  @Prop text: string = '暂无数据';

  build() {
    Column() {
      Text('🍽️')
        .fontSize(52)
      Text(this.text)
        .fontSize(14)
        .fontColor($r('app.color.text_hint'))
        .margin({ top: 14 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}