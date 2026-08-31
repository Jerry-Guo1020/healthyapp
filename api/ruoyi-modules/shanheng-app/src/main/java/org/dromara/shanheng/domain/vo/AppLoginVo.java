package org.dromara.shanheng.domain.vo;

import lombok.Data;

/**
 * App 登录结果视图
 *
 * @author shanheng
 */
@Data
public class AppLoginVo {

    /** 访问令牌 */
    private String token;

    /** 用户信息 */
    private AppUserInfoVo userInfo;

}