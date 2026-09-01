import { preferences } from '@kit.ArkData';
import { AppGlobal } from './AppGlobal';
import { Logger } from './Logger';

const TAG: string = 'StorageUtil';
const PREF_NAME: string = 'shanheng_healthyapp';

/**
 * 本地键值持久化封装（基于 preferences）
 */
export class StorageUtil {
  private static pref(): preferences.Preferences | null {
    if (AppGlobal.context == null) {
      Logger.warn(TAG, 'context is null, skip storage op');
      return null;
    }
    return preferences.getPreferencesSync(AppGlobal.context, { name: PREF_NAME });
  }

  static put(key: string, value: string): void {
    const p = StorageUtil.pref();
    if (p == null) {
      return;
    }
    p.putSync(key, value);
    p.flush();
  }

  static get(key: string, def: string = ''): string {
    const p = StorageUtil.pref();
    if (p == null) {
      return def;
    }
    return p.getSync(key, def) as string;
  }

  static remove(key: string): void {
    const p = StorageUtil.pref();
    if (p == null) {
      return;
    }
    p.deleteSync(key);
    p.flush();
  }
}