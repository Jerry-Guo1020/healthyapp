import { AppLoginVo, AppUserInfoVo } from '../model/ApiModels';
import { StorageUtil } from './StorageUtil';
import { STORAGE_KEY_TOKEN, STORAGE_KEY_USER } from './Constants';
import { Logger } from './Logger';

const TAG: string = 'UserSession';

/**
 * 登录态会话（内存态 + preferences 持久化）
 */
export class UserSession {
  static token: string = '';
  static userInfo: AppUserInfoVo | null = null;

  /** 应用启动时从本地恢复会话 */
  static init(): void {
    UserSession.token = StorageUtil.get(STORAGE_KEY_TOKEN, '');
    const userStr = StorageUtil.get(STORAGE_KEY_USER, '');
    if (userStr !== '') {
      try {
        UserSession.userInfo = JSON.parse(userStr) as AppUserInfoVo;
      } catch (e) {
        Logger.warn(TAG, 'parse cached user fail');
        UserSession.userInfo = null;
      }
    }
    Logger.info(TAG, `session init, login=${UserSession.isLogin()}`);
  }

  static isLogin(): boolean {
    return UserSession.token !== '';
  }

  static isGuest(): boolean {
    if (UserSession.userInfo == null) {
      return true;
    }
    return UserSession.userInfo.isGuest === 1;
  }

  static saveLogin(vo: AppLoginVo): void {
    UserSession.token = vo.token;
    UserSession.userInfo = vo.userInfo;
    StorageUtil.put(STORAGE_KEY_TOKEN, vo.token);
    StorageUtil.put(STORAGE_KEY_USER, JSON.stringify(vo.userInfo));
  }

  static updateUser(userInfo: AppUserInfoVo): void {
    UserSession.userInfo = userInfo;
    StorageUtil.put(STORAGE_KEY_USER, JSON.stringify(userInfo));
  }

  static logout(): void {
    UserSession.token = '';
    UserSession.userInfo = null;
    StorageUtil.remove(STORAGE_KEY_TOKEN);
    StorageUtil.remove(STORAGE_KEY_USER);
  }
}