import { authentication } from '@kit.AccountKit';
import { common } from '@kit.AbilityKit';
import { Logger } from '../common/Logger';

const TAG: string = 'HuaweiAuthService';

/**
 * 华为账号授权码
 */
export class HuaweiAuthCode {
  code: string = '';
  state: string = '';
}

/**
 * 华为账号服务（Account Kit）授权码模式封装。
 *
 * ⚠️ 接入前准备（必须在 AppGallery Connect 完成）：
 * 1. 注册华为开发者账号并实名认证
 * 2. AGC 创建 HarmonyOS 应用 → 获取 AppID / client_id / client_secret
 * 3. 开通「账号服务」(Account Kit)，勾选需授权的 scope（本文件用 openid + profile）
 * 4. 将真机调试的 SHA-256 证书指纹配置到 AGC
 *
 * 说明：client_id 由 AGC 依据应用签名指纹自动识别，SDK 侧无需填写；
 * client_secret 只在后端换 token 时使用（见后端 shanheng.huawei.* 配置）。
 */
export class HuaweiAuthService {

  /** 授权 scope：openid（必须）+ profile（昵称/头像） */
  static readonly SCOPES: string[] = ['openid', 'profile'];

  /**
   * 发起华为账号授权码登录，返回 authorization code 与 state。
   * 成功 → resolve { code, state }；失败 → reject BusinessError/Error
   */
  static async getAuthorizationCode(context: common.Context): Promise<HuaweiAuthCode> {
    const provider = new authentication.HuaweiIDProvider();
    const request = provider.createAuthorizationWithHuaweiIDRequest();
    request.scopes = HuaweiAuthService.SCOPES;
    const state: string = 'sh' + Date.now().toString(36);
    request.state = state;

    const controller = new authentication.AuthenticationController(context);
    const response = (await controller.executeRequest(request)) as authentication.AuthorizationWithHuaweiIDResponse;
    const credential = response.data;
    if (credential === undefined || credential.authorizationCode === undefined) {
      throw new Error('未获取到华为账号授权码');
    }

    const authCode = new HuaweiAuthCode();
    authCode.code = credential.authorizationCode;
    authCode.state = response.state !== undefined ? response.state : state;
    Logger.info(TAG, 'huawei auth code obtained');
    return authCode;
  }

  /**
   * 华为账号「一键登录」（获取手机号 + UnionID，scope=quickLoginAnonymousPhone）。
   * ⚠️ 仅企业开发者可用，需在 AGC 申请「华为账号一键登录」权限（审核约 3 工作日）；
   * 未开通时调用会报 1001502014，前端需降级引导用户走普通华为账号登录。
   */
  static async quickLogin(context: common.Context): Promise<HuaweiAuthCode> {
    const provider = new authentication.HuaweiIDProvider();
    const request = provider.createAuthorizationWithHuaweiIDRequest();
    request.scopes = ['quickLoginAnonymousPhone'];
    const state: string = 'sh' + Date.now().toString(36);
    request.state = state;

    const controller = new authentication.AuthenticationController(context);
    const response = (await controller.executeRequest(request)) as authentication.AuthorizationWithHuaweiIDResponse;
    const credential = response.data;
    if (credential === undefined || credential.authorizationCode === undefined) {
      throw new Error('未获取到一键登录授权码');
    }

    const authCode = new HuaweiAuthCode();
    authCode.code = credential.authorizationCode;
    authCode.state = response.state !== undefined ? response.state : state;
    Logger.info(TAG, 'huawei quick login code obtained');
    return authCode;
  }

}