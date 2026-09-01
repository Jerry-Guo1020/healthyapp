import { StorageUtil } from './StorageUtil';

const KEY_DEVICE_ID: string = 'shanheng_device_id';

/**
 * 设备标识（用于游客登录）
 */
export class DeviceUtil {
  static getDeviceId(): string {
    let id = StorageUtil.get(KEY_DEVICE_ID, '');
    if (id === '') {
      id = 'dev_' + Date.now().toString() + '_' + Math.floor(Math.random() * 100000).toString();
      StorageUtil.put(KEY_DEVICE_ID, id);
    }
    return id;
  }
}