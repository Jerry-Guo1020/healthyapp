import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { AgreementText } from '../common/AgreementText';

/**
 * 协议展示页。
 * 路由参数 type：'user'（用户协议）｜'privacy'（隐私政策）｜'huawei'（华为账号用户认证协议）
 * 华为协议通过 Web 组件加载官方链接，其余为内置全文展示。
 */
@Entry
@Component
struct AgreementPage {
  @State type: string = 'user';
  @State title: string = '用户协议';
  @State content: string = '';
  private controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params != null && params['type'] != null) {
      this.type = params['type'] as string;
    }
    if (this.type === 'privacy') {
      this.title = '隐私政策';
      this.content = AgreementText.PRIVACY_POLICY;
    } else if (this.type === 'huawei') {
      this.title = '华为账号用户认证协议';
      this.content = '';
    } else {
      this.title = '用户协议';
      this.content = AgreementText.USER_AGREEMENT;
    }
  }

  build() {
    Column() {
      // 顶部栏：返回 + 标题
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor('#333333')
          .width(40)
          .onClick(() => {
            router.back();
          })
        Text(this.title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Row()
          .width(40)
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })

      if (this.type === 'huawei') {
        // 华为账号用户认证协议：加载官方页面
        Web({ src: AgreementText.HUAWEI_URL, controller: this.controller })
          .width('100%')
          .layoutWeight(1)
      } else {
        Scroll() {
          Text(this.content)
            .fontSize(15)
            .fontColor('#333333')
            .lineHeight(24)
            .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 20, right: 20, top: 8, bottom: 32 })
        .align(Alignment.TopStart)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}