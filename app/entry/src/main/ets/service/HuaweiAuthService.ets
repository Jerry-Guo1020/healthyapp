import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
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
 * 5. 把 client_id 填入下方 HUAWEI_CLIENT_ID
 *
 * 未配置 client_id 时调用会直接进入 catch，登录页据此提示。
 */
export class HuaweiAuthService {

  /** AGC 应用 client_id（创建应用后从「项目设置 → 常规」获取，格式形如 10xxxx） */
  static readonly HUAWEI_CLIENT_ID: string = '';

  /** 授权 scope：openid（必须）+ profile（昵称/头像） */
  static readonly SCOPES: string[] = ['openid', 'profile'];

  /**
   * 发起华为账号授权码登录，返回 authorization code 与 state。
   * 成功 → resolve { code, state }；失败 → reject BusinessError
   */
  static getAuthorizationCode(): Promise<HuaweiAuthCode> {
    return new Promise<HuaweiAuthCode>((resolve, reject) => {
      if (HuaweiAuthService.HUAWEI_CLIENT_ID === '') {
        reject(new BusinessError('未配置华为账号服务：请在 HuaweiAuthService 中填入 AGC client_id'));
        return;
      }
      const state: string = 'sh' + Date.now().toString(36);
      const request: authentication.AuthorizationWithAuthorizationCodeRequest = {
        clientId: HuaweiAuthService.HUAWEI_CLIENT_ID,
        scope: HuaweiAuthService.SCOPES,
        state: state
      };
      authentication.createAuthorizationWithAuthorizationCodeRequest(request)
        .then((req: authentication.AuthorizationWithAuthorizationCodeRequestManager) => {
          return req.execute();
        })
        .then((result: authentication.AuthorizationWithAuthorizationCodeResult) => {
          const authCode = new HuaweiAuthCode();
          authCode.code = result.authorizationCode;
          authCode.state = result.state !== undefined ? result.state : state;
          Logger.info(TAG, 'huawei auth code obtained');
          resolve(authCode);
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `huawei auth failed: ${err.code} ${err.message}`);
          reject(err);
        });
    });
  }

}