package org.dromara.shanheng.domain.vo;

import lombok.Data;

/**
 * App 用户信息视图
 *
 * @author shanheng
 */
@Data
public class AppUserInfoVo {

    /** 用户ID */
    private Long id;

    /** 昵称 */
    private String nickname;

    /** 头像URL */
    private String avatarUrl;

    /** 是否游客 0否 1是 */
    private Integer isGuest;

}