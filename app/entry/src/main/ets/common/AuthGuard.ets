import { router, promptAction } from '@kit.ArkUI';
import { UserSession } from './UserSession';

/**
 * 登录守卫：需要「正式账号」（非游客）才能继续的功能统一在此校验。
 * 游客 / 未登录 → 提示并跳转登录页，返回 false；已登录 → true。
 */
export class AuthGuard {
  static requireAccount(): boolean {
    if (UserSession.isLogin() && !UserSession.isGuest()) {
      return true;
    }
    promptAction.showToast({ message: '请先登录后使用该功能' });
    router.pushUrl({ url: 'pages/login/LoginPage' });
    return false;
  }
}