import { router, promptAction } from '@kit.ArkUI';
import { UserSession } from '../../common/UserSession';

/**
 * 用户管理页：查看当前账号信息、登录方式，支持退出登录 / 前往登录。
 */
@Entry
@Component
struct AccountManagePage {
  @State nickname: string = '未登录';
  @State isGuest: number = 1;
  @State userId: string = '';
  @State loginWay: string = '未登录';

  aboutToAppear(): void {
    const u = UserSession.userInfo;
    if (u != null) {
      this.nickname = u.nickname;
      this.isGuest = u.isGuest;
      this.userId = u.id;
      this.loginWay = this.isGuest === 1 ? '未登录' : '华为账号';
    }
  }

  goLogin(): void {
    router.pushUrl({ url: 'pages/login/LoginPage' });
  }

  logout(): void {
    this.getUIContext().showAlertDialog({
      title: '退出登录',
      message: '确定要退出当前账号吗？',
      primaryButton: {
        value: '退出',
        action: () => {
          UserSession.logout();
          promptAction.showToast({ message: '已退出登录' });
          router.replaceUrl({ url: 'pages/login/LoginPage' });
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {
        }
      }
    });
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor('#1A1A1A')
          .width(40)
          .onClick(() => {
            router.back();
          })
        Text('用户管理')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .height(50)
      .padding({ left: 10, right: 16 })

      Scroll() {
        Column() {
          // 账号卡片
          Row() {
            Text('👤')
              .width(56)
              .height(56)
              .fontSize(28)
              .textAlign(TextAlign.Center)
              .backgroundColor('#00A86B1A')
              .borderRadius(28)
            Column() {
              Text(this.nickname)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
              Text(this.loginWay)
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
          .margin({ top: 8 })

          // 账号信息
          Column() {
            Text('账号信息')
              .fontSize(13)
              .fontColor('#999999')
              .width('100%')
              .margin({ top: 6, bottom: 6 })
            Row() {
              Text('用户身份')
                .fontSize(15)
                .fontColor('#1A1A1A')
              Blank()
              Text(this.isGuest === 1 ? '未登录' : '正式用户')
                .fontSize(13)
                .fontColor(this.isGuest === 1 ? '#F5A623' : '#00A86B')
            }
            .width('100%')
            .height(44)
            Row() {
              Text('用户编号')
                .fontSize(15)
                .fontColor('#1A1A1A')
              Blank()
              Text(this.userId === '' ? '-' : this.userId)
                .fontSize(13)
                .fontColor('#999999')
            }
            .width('100%')
            .height(44)
          }
          .width('92%')
          .padding({ left: 16, right: 16, bottom: 8 })
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
          .margin({ top: 12 })

          if (this.isGuest === 1) {
            Column() {
              Text('当前未登录，收藏、历史、健康分析、偏好等数据将在登录账号后云端同步保存。')
                .fontSize(13)
                .fontColor('#999999')
                .lineHeight(20)
                .width('100%')
              Button('前往登录')
                .width('100%')
                .height(44)
                .fontSize(15)
                .fontColor('#FFFFFF')
                .backgroundColor('#00A86B')
                .borderRadius(22)
                .margin({ top: 14 })
                .onClick(() => {
                  this.goLogin();
                })
            }
            .width('92%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
            .margin({ top: 12 })
          } else {
            Button('退出登录')
              .width('92%')
              .height(48)
              .fontSize(16)
              .fontColor('#E5484D')
              .backgroundColor('#FFFFFF')
              .margin({ top: 16 })
              .onClick(() => {
                this.logout();
              })
          }
        }
        .width('100%')
        .padding({ bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}