import { router } from '@kit.ArkUI';
import { UserSession } from '../common/UserSession';

/**
 * 启动页：恢复会话并路由分发
 */
@Entry
@Component
struct Index {
  aboutToAppear(): void {
    UserSession.init();
    setTimeout(() => {
      const target: string = UserSession.isLogin() ? 'pages/MainPage' : 'pages/LoginPage';
      router.replaceUrl({ url: target });
    }, 600);
  }

  build() {
    Column() {
      Text('膳衡')
        .fontSize(44)
        .fontWeight(FontWeight.Bold)
        .fontColor('#00A86B')
      Text('健康饮食 · 膳衡相伴')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 14 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}