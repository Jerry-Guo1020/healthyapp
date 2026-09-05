import { ApiClient } from './ApiClient';
import { ApiResult, AppLoginVo } from '../model/ApiModels';

// 请求体（ArkTS 禁止无类型对象字面量，定义显式类）
class GuestLoginBody {
  deviceId: string = '';
}

class SendCodeBody {
  phone: string = '';
}

class LoginByCodeBody {
  phone: string = '';
  code: string = '';
}

class HuaweiLoginBody {
  code: string = '';
  state: string = '';
}

class HuaweiQuickLoginBody {
  unionId: string = '';
  openId: string = '';
}

/**
 * 认证接口
 */
export class AuthApi {
  /** 游客登录 */
  static async guestLogin(deviceId: string): Promise<ApiResult<AppLoginVo>> {
    const body = new GuestLoginBody();
    body.deviceId = deviceId;
    return ApiClient.post<AppLoginVo>('/auth/guest', body);
  }

  /** 发送验证码 */
  static async sendCode(phone: string): Promise<ApiResult<object>> {
    const body = new SendCodeBody();
    body.phone = phone;
    return ApiClient.post<object>('/auth/send-code', body);
  }

  /** 验证码登录 */
  static async loginByCode(phone: string, code: string): Promise<ApiResult<AppLoginVo>> {
    const body = new LoginByCodeBody();
    body.phone = phone;
    body.code = code;
    return ApiClient.post<AppLoginVo>('/auth/login-by-code', body);
  }

  /** 华为账号授权码登录（openid + profile 授权码模式） */
  static async huaweiLogin(code: string, state: string): Promise<ApiResult<AppLoginVo>> {
    const body = new HuaweiLoginBody();
    body.code = code;
    body.state = state;
    return ApiClient.post<AppLoginVo>('/auth/huawei-login', body);
  }

  /** 华为账号一键登录（LoginWithHuaweiIDButton 组件回调直接返回 unionId/openId，无需 code） */
  static async huaweiQuickLogin(unionId: string, openId: string): Promise<ApiResult<AppLoginVo>> {
    const body = new HuaweiQuickLoginBody();
    body.unionId = unionId;
    body.openId = openId;
    return ApiClient.post<AppLoginVo>('/auth/huawei-login', body);
  }

  /** 登出（无状态 JWT，客户端丢弃即可） */
  static async logout(): Promise<ApiResult<object>> {
    return ApiClient.post<object>('/auth/logout', null);
  }
}