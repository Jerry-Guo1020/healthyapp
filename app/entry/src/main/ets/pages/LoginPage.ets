import { router, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AuthApi } from '../service/AuthApi';
import { UserSession } from '../common/UserSession';
import { DeviceUtil } from '../common/DeviceUtil';
import { Logger } from '../common/Logger';
import { HuaweiAuthService, HuaweiAuthCode } from '../service/HuaweiAuthService';

const TAG: string = 'LoginPage';

// 协议页路由参数（ArkTS 禁止无类型对象字面量）
class AgreementParams {
  type: string = 'user';
}

/**
 * 登录页：华为账号一键登录 + 华为账号登录 + 游客体验。
 * 登录前须勾选并同意《用户协议》《隐私政策》《华为账号用户认证协议》（参照华为一键登录 UX 规范）。
 * 一键登录权限未开通前，前端界面已就绪，点击会降级引导使用华为账号登录。
 */
@Entry
@Component
struct LoginPage {
  @State quickLoading: boolean = false;
  @State huaweiLoading: boolean = false;
  @State guestLoading: boolean = false;
  @State agreed: boolean = false;

  /** 所有登录操作前置校验：必须勾选协议 */
  private checkAgreed(): boolean {
    if (!this.agreed) {
      promptAction.showToast({ message: '请先阅读并同意相关协议' });
      return false;
    }
    return true;
  }

  private openAgreement(type: string): void {
    const p = new AgreementParams();
    p.type = type;
    router.pushUrl({
      url: 'pages/AgreementPage',
      params: p
    });
  }

  private hostContext(): common.Context | undefined {
    return this.getUIContext().getHostContext();
  }

  private goMain(): void {
    router.replaceUrl({ url: 'pages/MainPage' });
  }

  /** 华为账号一键登录（获取手机号，需企业权限，审核中则降级） */
  onQuickLogin(): void {
    if (!this.checkAgreed()) {
      return;
    }
    if (this.quickLoading) {
      return;
    }
    this.quickLoading = true;
    const ctx = this.hostContext();
    if (ctx === undefined) {
      this.quickLoading = false;
      promptAction.showToast({ message: '无法获取应用上下文' });
      return;
    }
    HuaweiAuthService.quickLogin(ctx).then((authCode: HuaweiAuthCode) => {
      return AuthApi.huaweiLogin(authCode.code, authCode.state);
    }).then((res) => {
      this.quickLoading = false;
      if (res.code === 200 && res.data != null) {
        UserSession.saveLogin(res.data);
        Logger.info(TAG, 'quick login success');
        this.goMain();
      }
    }).catch((err: BusinessError) => {
      this.quickLoading = false;
      Logger.warn(TAG, `quick login fail: ${err.message}`);
      promptAction.showToast({ message: '一键登录审核中，请使用华为账号登录' });
    });
  }

  /** 华为账号登录（授权码模式，首次登录自动注册） */
  onHuaweiLogin(): void {
    if (!this.checkAgreed()) {
      return;
    }
    if (this.huaweiLoading) {
      return;
    }
    this.huaweiLoading = true;
    const ctx = this.hostContext();
    if (ctx === undefined) {
      this.huaweiLoading = false;
      promptAction.showToast({ message: '无法获取应用上下文' });
      return;
    }
    HuaweiAuthService.getAuthorizationCode(ctx).then((authCode: HuaweiAuthCode) => {
      return AuthApi.huaweiLogin(authCode.code, authCode.state);
    }).then((res) => {
      this.huaweiLoading = false;
      if (res.code === 200 && res.data != null) {
        UserSession.saveLogin(res.data);
        Logger.info(TAG, 'huawei login success');
        this.goMain();
      }
    }).catch((err: BusinessError) => {
      this.huaweiLoading = false;
      Logger.error(TAG, `huawei login fail: ${err.message}`);
      promptAction.showToast({ message: '华为登录失败，请稍后重试' });
    });
  }

  /** 游客体验（不注册账号，数据暂存本地） */
  onGuestLogin(): void {
    if (!this.checkAgreed()) {
      return;
    }
    if (this.guestLoading) {
      return;
    }
    this.guestLoading = true;
    AuthApi.guestLogin(DeviceUtil.getDeviceId()).then((res) => {
      this.guestLoading = false;
      if (res.code === 200 && res.data != null) {
        UserSession.saveLogin(res.data);
        Logger.info(TAG, 'guest login success');
        this.goMain();
      }
    });
  }

  build() {
    Column() {
      Column() {
        Text('膳衡')
          .fontSize(44)
          .fontWeight(FontWeight.Bold)
          .fontColor('#00A86B')
        Text('懂你的健康，也懂你的胃')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 10 })
      }
      .margin({ top: 110 })

      Column() {
        // 一键登录（主按钮）
        Button(this.quickLoading ? '正在登录...' : '一键登录')
          .width('100%')
          .height(52)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#CF0A2C')
          .enabled(!this.quickLoading)
          .onClick(() => {
            this.onQuickLogin();
          })

        Text('未开通一键登录的企业权限前，将自动降级为华为账号登录')
          .fontSize(11)
          .fontColor('#BBBBBB')
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 8 })

        Divider()
          .margin({ top: 20, bottom: 16 })

        // 华为账号登录（次按钮）
        Button(this.huaweiLoading ? '正在登录...' : '华为账号登录')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor('#CF0A2C')
          .backgroundColor('#CF0A2C12')
          .enabled(!this.huaweiLoading)
          .onClick(() => {
            this.onHuaweiLogin();
          })

        // 游客体验
        Button(this.guestLoading ? '进入中...' : '游客体验')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor('#00A86B')
          .backgroundColor('#FFFFFF')
          .margin({ top: 14 })
          .enabled(!this.guestLoading)
          .onClick(() => {
            this.onGuestLogin();
          })

        // 协议勾选区（参照华为一键登录 UX：未勾选不可登录）
        Row() {
          Checkbox()
            .select(this.agreed)
            .selectedColor('#00A86B')
            .width(18)
            .height(18)
            .margin({ right: 6 })
            .onChange((value: boolean) => {
              this.agreed = value;
            })
          Text('我已阅读并同意')
            .fontSize(12)
            .fontColor('#999999')
          Text('《用户协议》')
            .fontSize(12)
            .fontColor('#00A86B')
            .onClick(() => {
              this.openAgreement('user');
            })
          Text('《隐私政策》')
            .fontSize(12)
            .fontColor('#00A86B')
            .onClick(() => {
              this.openAgreement('privacy');
            })
        }
        .width('100%')
        .margin({ top: 18 })
        .alignItems(VerticalAlign.Center)

        Row() {
          Text('《华为账号用户认证协议》')
            .fontSize(12)
            .fontColor('#00A86B')
            .margin({ left: 24 })
            .onClick(() => {
              this.openAgreement('huawei');
            })
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .width('86%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ top: 44 })

      Text('登录即代表同意相关协议，数据将安全存储于云端')
        .fontSize(11)
        .fontColor('#BBBBBB')
        .margin({ top: 22 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}