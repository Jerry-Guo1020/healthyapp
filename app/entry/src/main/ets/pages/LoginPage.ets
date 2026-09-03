import { router, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AuthApi } from '../service/AuthApi';
import { UserSession } from '../common/UserSession';
import { DeviceUtil } from '../common/DeviceUtil';
import { Logger } from '../common/Logger';
import { HuaweiAuthService, HuaweiAuthCode } from '../service/HuaweiAuthService';

const TAG: string = 'LoginPage';

/**
 * 登录页：手机验证码登录 + 游客一键登录
 */
@Entry
@Component
struct LoginPage {
  @State phone: string = '';
  @State code: string = '';
  @State countdown: number = 0;
  @State loading: boolean = false;
  @State guestLoading: boolean = false;
  @State huaweiLoading: boolean = false;
  private timerId: number = -1;

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  isValidPhone(): boolean {
    return this.phone.length === 11;
  }

  onSendCode(): void {
    if (!this.isValidPhone()) {
      promptAction.showToast({ message: '请输入 11 位手机号' });
      return;
    }
    AuthApi.sendCode(this.phone).then((res) => {
      if (res.code === 200) {
        promptAction.showToast({ message: '验证码已发送' });
        this.countdown = 60;
        this.timerId = setInterval(() => {
          this.countdown--;
          if (this.countdown <= 0) {
            clearInterval(this.timerId);
            this.timerId = -1;
          }
        }, 1000);
      }
    });
  }

  goMain(): void {
    router.replaceUrl({ url: 'pages/MainPage' });
  }

  onLoginByCode(): void {
    if (!this.isValidPhone()) {
      promptAction.showToast({ message: '请输入 11 位手机号' });
      return;
    }
    if (this.code.length === 0) {
      promptAction.showToast({ message: '请输入验证码' });
      return;
    }
    this.loading = true;
    AuthApi.loginByCode(this.phone, this.code).then((res) => {
      this.loading = false;
      if (res.code === 200 && res.data != null) {
        UserSession.saveLogin(res.data);
        Logger.info(TAG, 'login by code success');
        this.goMain();
      }
    });
  }

  onGuestLogin(): void {
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

  onHuaweiLogin(): void {
    if (this.huaweiLoading) {
      return;
    }
    this.huaweiLoading = true;
    const ctx: common.Context | undefined = this.getUIContext().getHostContext();
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

  build() {
    Column() {
      Column() {
        Text('膳衡')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#00A86B')
        Text('健康饮食 · 膳衡相伴')
          .fontSize(13)
          .fontColor('#999999')
          .margin({ top: 8 })
      }
      .margin({ top: 90 })

      Column() {
        TextInput({ placeholder: '请输入手机号', text: this.phone })
          .type(InputType.PhoneNumber)
          .maxLength(11)
          .height(50)
          .fontSize(15)
          .backgroundColor('#F5F6F7')
          .onChange((value: string) => {
            this.phone = value;
          })

        Row() {
          TextInput({ placeholder: '请输入验证码', text: this.code })
            .type(InputType.Number)
            .maxLength(6)
            .height(50)
            .fontSize(15)
            .backgroundColor('#F5F6F7')
            .layoutWeight(1)
            .onChange((value: string) => {
              this.code = value;
            })
          Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
            .height(50)
            .width(110)
            .fontSize(13)
            .fontColor(this.countdown > 0 ? '#999999' : '#00A86B')
            .backgroundColor('#FFFFFF')
            .enabled(this.countdown === 0)
            .margin({ left: 10 })
            .onClick(() => {
              this.onSendCode();
            })
        }
        .width('100%')
        .margin({ top: 14 })

        Button('登录')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#00A86B')
          .enabled(!this.loading)
          .margin({ top: 20 })
          .onClick(() => {
            this.onLoginByCode();
          })

        Divider()
          .margin({ top: 24, bottom: 16 })

        Button('一键游客登录')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor('#00A86B')
          .backgroundColor('#00A86B1A')
          .margin({ top: 14 })
          .enabled(!this.guestLoading)
          .onClick(() => {
            this.onGuestLogin();
          })

        Button('华为账号登录')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#CF0A2C')
          .margin({ top: 14 })
          .enabled(!this.huaweiLoading)
          .onClick(() => {
            this.onHuaweiLogin();
          })
      }
      .width('86%')
      .padding(22)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ top: 40 })

      Text('游客可先体验，登录后数据可云端同步')
        .fontSize(11)
        .fontColor('#BBBBBB')
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}