import { router, promptAction } from '@kit.ArkUI';
import { UserSession } from '../../common/UserSession';

/**
 * 我的 Tab
 */
@Component
export struct ProfileTab {
  @Prop @Watch('onActiveChange') active: boolean = false;
  @State nickname: string = '未登录';
  @State isGuest: number = 1;

  aboutToAppear(): void {
    this.refreshUser();
  }

  onActiveChange(): void {
    if (this.active) {
      this.refreshUser();
    }
  }

  refreshUser(): void {
    const u = UserSession.userInfo;
    if (u != null) {
      this.nickname = u.nickname;
      this.isGuest = u.isGuest;
    } else {
      this.nickname = '未登录';
      this.isGuest = 1;
    }
  }

  onLogout(): void {
    UserSession.logout();
    promptAction.showToast({ message: '已退出登录' });
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  build() {
    Column() {
      Row() {
        Text('我的')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 12 })

      // 用户卡片
      Row() {
        Text('👤')
          .width(60)
          .height(60)
          .fontSize(30)
          .textAlign(TextAlign.Center)
          .backgroundColor('#00A86B1A')
          .borderRadius(30)
        Column() {
          Text(this.nickname)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
          Text(this.isGuest === 1 ? '游客模式（登录后可同步数据）' : '已登录用户')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 14 })
      }
      .width('92%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(14)
      .margin({ top: 6 })

      // 关于
      Column() {
        Row() {
          Text('关于膳衡')
            .fontSize(15)
            .fontColor('#1A1A1A')
          Blank()
          Text('v1.0.0')
            .fontSize(13)
            .fontColor('#999999')
        }
        .width('100%')
        .height(50)
      }
      .width('92%')
      .padding({ left: 18, right: 18 })
      .backgroundColor('#FFFFFF')
      .borderRadius(14)
      .margin({ top: 14 })

      // 退出登录
      Button('退出登录')
        .width('92%')
        .height(48)
        .fontSize(16)
        .fontColor('#E5484D')
        .backgroundColor('#FFFFFF')
        .margin({ top: 24 })
        .onClick(() => {
          this.onLogout();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}