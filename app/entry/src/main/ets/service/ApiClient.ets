import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { BASE_URL, APP_API_PREFIX } from '../common/Constants';
import { ApiResult } from '../model/ApiModels';
import { UserSession } from '../common/UserSession';
import { Logger } from '../common/Logger';

const TAG: string = 'ApiClient';

/**
 * HTTP 请求封装：统一 baseUrl 拼接、Token 注入、JSON 解析、错误码处理
 */
export class ApiClient {

  static async get<T>(path: string): Promise<ApiResult<T>> {
    return ApiClient.request<T>(http.RequestMethod.GET, path, null);
  }

  static async post<T>(path: string, body: object | null): Promise<ApiResult<T>> {
    return ApiClient.request<T>(http.RequestMethod.POST, path, body);
  }

  static async del<T>(path: string): Promise<ApiResult<T>> {
    return ApiClient.request<T>(http.RequestMethod.DELETE, path, null);
  }

  static async put<T>(path: string, body: object | null): Promise<ApiResult<T>> {
    return ApiClient.request<T>(http.RequestMethod.PUT, path, body);
  }

  private static async request<T>(method: http.RequestMethod, path: string,
    body: object | null): Promise<ApiResult<T>> {
    const client = http.createHttp();
    const url = BASE_URL + APP_API_PREFIX + path;
    const headers: Record<string, string> = { 'Content-Type': 'application/json' };
    if (UserSession.token !== '') {
      headers['Authorization'] = 'Bearer ' + UserSession.token;
    }

    try {
      const resp = await client.request(url, {
        method: method,
        header: headers,
        extraData: body == null ? undefined : JSON.stringify(body),
        connectTimeout: 10000,
        readTimeout: 20000,
        expectDataType: http.HttpDataType.STRING
      });
      const text = resp.result as string;
      const data = JSON.parse(text) as ApiResult<T>;
      if (data.code === 200) {
        return data;
      }
      if (data.code === 401) {
        UserSession.logout();
        promptAction.showToast({ message: '登录已过期，请重新登录' });
      } else {
        const msg = data.msg === '' ? '请求失败' : data.msg;
        promptAction.showToast({ message: msg });
      }
      return data;
    } catch (e) {
      const err = e as BusinessError;
      Logger.error(TAG, `request fail: ${err.code} ${err.message} url=${url}`);
      promptAction.showToast({ message: '网络异常，请检查网络后重试' });
      const fail = new ApiResult<T>();
      fail.code = -1;
      fail.msg = '网络异常，请稍后重试';
      return fail;
    } finally {
      client.destroy();
    }
  }
}