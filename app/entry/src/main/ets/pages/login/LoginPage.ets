import { router, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AuthApi } from '../../service/AuthApi';
import { UserSession } from '../../common/UserSession';
import { DeviceUtil } from '../../common/DeviceUtil';
import { Logger } from '../../common/Logger';
import { HuaweiAuthService, HuaweiAuthCode } from '../../service/HuaweiAuthService';
import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';

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
  @State anonymousPhone: string = '';

  /** 一键登录按钮 controller（协议状态 + 点击回调），回调在 aboutToAppear 里绑定 */
  private quickController: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController();

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
      url: 'pages/agreement/AgreementPage',
      params: p
    });
  }

  private hostContext(): common.Context | undefined {
    return this.getUIContext().getHostContext();
  }

  private goMain(): void {
    router.replaceUrl({ url: 'pages/main/MainPage' });
  }

  /** 组件挂载：绑定一键登录按钮的协议状态与点击回调 */
  aboutToAppear(): void {
    this.quickController
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError | undefined,
        credential: loginComponentManager.HuaweiIDCredential): void => {
        this.handleQuickLogin(error, credential);
      });
    this.fetchAnonymousPhone();
  }

  /** 拉取一键登录匿名手机号（打码态），拿不到仅不展示不阻断 */
  private fetchAnonymousPhone(): void {
    const ctx = this.hostContext();
    if (ctx === undefined) {
      return;
    }
    HuaweiAuthService.getQuickLoginAnonymousPhone(ctx).then((phone: string) => {
      if (phone !== '') {
        this.anonymousPhone = phone;
        Logger.info(TAG, `anonymous phone obtained: ${phone}`);
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `get anonymous phone fail: ${err.message}`);
    });
  }

  /** 构造一键登录按钮参数（显式声明尺寸，保险避免官方组件默认大尺寸渲染） */
  private buildQuickLoginParams(): loginComponentManager.LoginWithHuaweiIDButtonParams {
    const btnSize: loginComponentManager.ButtonSize = {
      width: '100%',
      height: 52
    };
    const btnStyle: loginComponentManager.ButtonStyle =
      new loginComponentManager.ButtonStyle().buttonSize(btnSize);
    const extraStyle: loginComponentManager.ExtraStyle = {
      buttonStyle: btnStyle
    };
    const params: loginComponentManager.LoginWithHuaweiIDButtonParams = {
      style: loginComponentManager.Style.BUTTON_RED,
      loginType: loginComponentManager.LoginType.QUICK_LOGIN,
      borderRadius: 26,
      supportDarkMode: true,
      extraStyle: extraStyle
    };
    return params;
  }

  /** 华为账号一键登录：组件回调返回 unionId/openId，直传后端登录 */
  private handleQuickLogin(error: BusinessError | undefined,
    credential: loginComponentManager.HuaweiIDCredential): void {
    if (error) {
      this.quickLoading = false;
      Logger.error(TAG, `quick login error: ${error.code} ${error.message}`);
      if (error.code === 1005300001) {
        promptAction.showToast({ message: '请先阅读并同意相关协议' });
      } else if (error.code === 1001502012) {
        // 用户取消授权，无需提示
      } else if (error.code === 1001502014) {
        promptAction.showToast({ message: '一键登录权限未开通，请使用华为账号登录' });
      } else {
        promptAction.showToast({ message: '一键登录失败，请稍后重试或使用华为账号登录' });
      }
      return;
    }
    const unionId: string = credential.unionID;
    if (unionId === '') {
      this.quickLoading = false;
      promptAction.showToast({ message: '未获取到华为 UnionID，请使用华为账号登录' });
      return;
    }
    if (this.quickLoading) {
      return;
    }
    this.quickLoading = true;
    this.quickController.setEnabled(false);
    const authorizationCode: string = credential.authorizationCode ?? '';
    Logger.info(TAG, `quick login unionId=${unionId}, hasAuthCode=${authorizationCode !== ''}`);
    AuthApi.huaweiQuickLogin(authorizationCode, unionId, credential.openID).then((res) => {
      this.quickLoading = false;
      this.quickController.setEnabled(true);
      if (res.code === 200 && res.data != null) {
        UserSession.saveLogin(res.data);
        Logger.info(TAG, 'quick login success');
        this.goMain();
      } else {
        promptAction.showToast({ message: res.msg !== '' ? res.msg : '一键登录失败' });
      }
    }).catch((err: BusinessError) => {
      this.quickLoading = false;
      this.quickController.setEnabled(true);
      Logger.error(TAG, `quick login request fail: ${err.message}`);
      promptAction.showToast({ message: '网络异常，请稍后重试' });
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
          .fontColor($r('app.color.brand'))
        Text('懂你的健康，也懂你的胃')
          .fontSize(14)
          .fontColor($r('app.color.text_sub'))
          .margin({ top: 10 })
      }
      .margin({ top: 110 })

      Column() {
        // 匿名手机号展示（华为一键登录 UX 规范：展示从华为账号侧获取的打码手机号）
        if (this.anonymousPhone !== '') {
          Column() {
            Text(this.anonymousPhone)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_main'))
            Text('华为账号绑定号码')
              .fontSize(12)
              .fontColor($r('app.color.text_sub'))
              .margin({ top: 4 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 16 })
        }

        // 一键登录（华为官方组件，尺寸经 extraStyle.buttonSize 控制，避免默认尺寸过大）
        LoginWithHuaweiIDButton({
          params: this.buildQuickLoginParams(),
          controller: this.quickController
        })

        Text('点击上方按钮，将通过华为账号授权一键登录')
          .fontSize(11)
          .fontColor($r('app.color.text_hint'))
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
          .fontColor($r('app.color.brand'))
          .backgroundColor($r('app.color.bg_card'))
          .margin({ top: 14 })
          .enabled(!this.guestLoading)
          .onClick(() => {
            this.onGuestLogin();
          })

        // 协议勾选区（参照华为一键登录 UX：未勾选不可登录）
        Row() {
          Checkbox()
            .select(this.agreed)
            .selectedColor($r('app.color.brand'))
            .width(18)
            .height(18)
            .margin({ right: 6 })
            .onChange((value: boolean) => {
              this.agreed = value;
              this.quickController.setAgreementStatus(value
                ? loginComponentManager.AgreementStatus.ACCEPTED
                : loginComponentManager.AgreementStatus.NOT_ACCEPTED);
            })
          Text('我已阅读并同意')
            .fontSize(12)
            .fontColor($r('app.color.text_sub'))
          Text('《用户协议》')
            .fontSize(12)
            .fontColor($r('app.color.brand'))
            .onClick(() => {
              this.openAgreement('user');
            })
          Text('《隐私政策》')
            .fontSize(12)
            .fontColor($r('app.color.brand'))
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
            .fontColor($r('app.color.brand'))
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
      .backgroundColor($r('app.color.bg_card'))
      .borderRadius(16)
      .margin({ top: 44 })

      Text('登录即代表同意相关协议，数据将安全存储于云端')
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))
        .margin({ top: 22 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_page'))
  }
}