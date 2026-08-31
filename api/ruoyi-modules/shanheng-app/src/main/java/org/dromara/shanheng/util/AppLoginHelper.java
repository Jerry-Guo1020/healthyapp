package org.dromara.shanheng.util;

/**
 * App 登录上下文持有器（ThreadLocal）
 *
 * @author shanheng
 */
public class AppLoginHelper {

    private static final ThreadLocal<AppLoginUser> HOLDER = new ThreadLocal<>();

    private AppLoginHelper() {
    }

    public static void setUser(AppLoginUser user) {
        HOLDER.set(user);
    }

    public static AppLoginUser getUser() {
        return HOLDER.get();
    }

    /** 当前登录用户ID，未登录/游客鉴权失败时为 null */
    public static Long getUserId() {
        AppLoginUser user = HOLDER.get();
        return user != null ? user.getUserId() : null;
    }

    public static boolean isGuest() {
        AppLoginUser user = HOLDER.get();
        return user != null && user.isGuest();
    }

    public static void clear() {
        HOLDER.remove();
    }

}