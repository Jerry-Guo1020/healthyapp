import { ApiClient } from './ApiClient';
import { ApiResult, AppLoginVo } from '../model/ApiModels';

/**
 * 认证接口
 */
export class AuthApi {
  /** 游客登录 */
  static async guestLogin(deviceId: string): Promise<ApiResult<AppLoginVo>> {
    return ApiClient.post<AppLoginVo>('/auth/guest', { deviceId: deviceId });
  }

  /** 发送验证码 */
  static async sendCode(phone: string): Promise<ApiResult<object>> {
    return ApiClient.post<object>('/auth/send-code', { phone: phone });
  }

  /** 验证码登录 */
  static async loginByCode(phone: string, code: string): Promise<ApiResult<AppLoginVo>> {
    return ApiClient.post<AppLoginVo>('/auth/login-by-code', { phone: phone, code: code });
  }

  /** 登出（无状态 JWT，客户端丢弃即可） */
  static async logout(): Promise<ApiResult<object>> {
    return ApiClient.post<object>('/auth/logout', null);
  }
}