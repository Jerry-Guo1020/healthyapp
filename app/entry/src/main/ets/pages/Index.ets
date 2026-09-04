import { router } from '@kit.ArkUI';
import { UserSession } from '../common/UserSession';
import { HealthAuthState } from '../common/HealthAuthState';
import { DeviceUtil } from '../common/DeviceUtil';
import { AuthApi } from '../service/AuthApi';
import { Logger } from '../common/Logger';

const TAG: string = 'Index';

/**
 * 启动页：恢复会话 → 未登录则静默游客登录 → 直接进入主界面。
 * 展示类功能（首页/搜索/详情/拍照识食）游客即可用；需要账号的详细功能
 * 在各自入口通过 AuthGuard.requireAccount() 校验再跳登录页。
 */
@Entry
@Component
struct Index {
  aboutToAppear(): void {
    UserSession.init();
    HealthAuthState.init();
    setTimeout(() => {
      if (UserSession.isLogin()) {
        router.replaceUrl({ url: 'pages/MainPage' });
        return;
      }
      // 静默游客登录，保证首页等展示类功能可用
      AuthApi.guestLogin(DeviceUtil.getDeviceId()).then((res) => {
        if (res.code === 200 && res.data != null) {
          UserSession.saveLogin(res.data);
        }
        router.replaceUrl({ url: 'pages/MainPage' });
      }).catch((err: Error) => {
        Logger.warn(TAG, `guest login fail: ${err.message}`);
        router.replaceUrl({ url: 'pages/MainPage' });
      });
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