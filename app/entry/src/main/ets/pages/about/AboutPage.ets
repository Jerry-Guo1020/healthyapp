import { router } from '@kit.ArkUI';

// 协议页路由参数（ArkTS 禁止无类型对象字面量）
class AgreementParams {
  type: string = 'user';
}

/**
 * 关于膳衡页：应用介绍、开发者信息、版本、协议入口
 */
@Entry
@Component
struct AboutPage {
  private openAgreement(type: string): void {
    const p = new AgreementParams();
    p.type = type;
    router.pushUrl({
      url: 'pages/agreement/AgreementPage',
      params: p
    });
  }

  @Builder
  sectionTitle(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor($r('app.color.text_sub'))
      .width('100%')
      .margin({ top: 18, bottom: 8 })
  }

  @Builder
  rowItem(label: string, value: string, clickable: boolean, type: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor($r('app.color.text_main'))
      Blank()
      Text(value)
        .fontSize(13)
        .fontColor(clickable ? $r('app.color.brand') : $r('app.color.text_sub'))
      if (clickable) {
        Text(' ›')
          .fontSize(14)
          .fontColor($r('app.color.text_hint'))
          .margin({ left: 4 })
      }
    }
    .width('100%')
    .height(46)
    .onClick(() => {
      if (clickable) {
        this.openAgreement(type);
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor($r('app.color.text_main'))
          .width(40)
          .onClick(() => {
            router.back();
          })
        Text('关于膳衡')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_main'))
      }
      .width('100%')
      .height(50)
      .padding({ left: 10, right: 16 })

      Scroll() {
        Column() {
          // Logo + 简介
          Column() {
            Text('🥗')
              .fontSize(56)
            Text('膳衡')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand'))
              .margin({ top: 10 })
            Text('懂你的健康，也懂你的胃')
              .fontSize(13)
              .fontColor($r('app.color.text_sub'))
              .margin({ top: 6 })
            Text('版本 v1.0.0')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
              .margin({ top: 12 })
          }
          .width('92%')
          .padding({ top: 30, bottom: 26 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(14)
          .margin({ top: 8 })

          // 应用介绍
          Column() {
            this.sectionTitle('应用简介')
            Text('膳衡是一款面向华为用户的「今天吃什么」健康饮食决策助手。围绕"吃什么"这一日常难题，提供菜品浏览与搜索、拍照识食、健康数据分析与个性化推荐等能力，用数据帮你科学地决定每一餐。')
              .fontSize(14)
              .fontColor($r('app.color.text_mid'))
              .lineHeight(22)
              .width('100%')
          }
          .width('92%')
          .padding(16)
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(14)
          .margin({ top: 12 })

          // 开发者信息
          Column() {
            this.sectionTitle('开发者信息')
            this.rowItem('运营主体', '清远市粤叁科技发展有限公司', false, '')
            this.rowItem('应用名称', '膳衡健康饮食助手', false, '')
          }
          .width('92%')
          .padding({ left: 16, right: 16, bottom: 8 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(14)
          .margin({ top: 12 })

          // 协议入口
          Column() {
            this.sectionTitle('协议与政策')
            this.rowItem('用户协议', '查看', true, 'user')
            Divider().color($r('app.color.bg_divider'))
            this.rowItem('隐私政策', '查看', true, 'privacy')
            Divider().color($r('app.color.bg_divider'))
            this.rowItem('华为账号用户认证协议', '查看', true, 'huawei')
          }
          .width('92%')
          .padding({ left: 16, right: 16, bottom: 8 })
          .backgroundColor($r('app.color.bg_card'))
          .borderRadius(14)
          .margin({ top: 12, bottom: 24 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_page'))
  }
}