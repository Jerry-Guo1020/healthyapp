package org.dromara.shanheng.util;

import lombok.Data;

/**
 * App 登录用户上下文
 *
 * @author shanheng
 */
@Data
public class AppLoginUser {

    /** 用户ID */
    private final Long userId;

    /** 是否游客 */
    private final boolean isGuest;

}