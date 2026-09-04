import { StorageUtil } from './StorageUtil';
import { STORAGE_KEY_HEALTH_AUTH } from './Constants';

/**
 * 健康数据授权状态（全局共享 + 本地持久化）。
 *
 * 作用：让「我的」的健康授权卡与「健康」的华为同步卡共用同一份状态，
 * 解决两个入口不联动的问题。真正的华为 Health Kit 授权发生在
 * HuaweiHealthService.syncAndArchive 中，成功后调用 setAuthorized(true)。
 */
export class HealthAuthState {
  static authorized: boolean = false;

  /** 应用启动时从本地恢复 */
  static init(): void {
    HealthAuthState.authorized = StorageUtil.get(STORAGE_KEY_HEALTH_AUTH, '0') === '1';
  }

  static isAuthorized(): boolean {
    return HealthAuthState.authorized;
  }

  static setAuthorized(v: boolean): void {
    HealthAuthState.authorized = v;
    StorageUtil.put(STORAGE_KEY_HEALTH_AUTH, v ? '1' : '0');
  }
}