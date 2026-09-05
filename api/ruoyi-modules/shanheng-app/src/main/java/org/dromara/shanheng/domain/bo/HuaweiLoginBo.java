package org.dromara.shanheng.domain.bo;

import lombok.Data;

/**
 * 华为账号登录请求体。
 * <p>
 * 支持两种模式（二选一，code 优先）：
 * <ul>
 *   <li>普通华为账号登录（openid + profile 授权码模式）：只传 {@code code}，
 *       后端用 code 换取 access_token 再读用户信息（UnionID/OpenID/昵称/头像）。</li>
 *   <li>华为账号一键登录（LoginWithHuaweiIDButton 组件）：组件回调直接返回
 *       {@code unionId}/{@code openId}，无需 code 换 token，前端直传这两个字段即可；
 *       手机号获取需走 {@code /oauth2/v6/quickLogin/getPhoneNumber}（后续增强）。</li>
 * </ul>
 *
 * @author shanheng
 */
@Data
public class HuaweiLoginBo {

    /** 华为授权码（普通华为账号登录） */
    private String code;

    /** UnionID（一键登录组件回调返回） */
    private String unionId;

    /** OpenID（一键登录组件回调返回，可选） */
    private String openId;

    /** 昵称（可选，一键登录组件返回时透传） */
    private String nickname;

    /** 头像（可选，一键登录组件返回时透传） */
    private String avatarUrl;

    /** 状态位（原样回传，防 CSRF，可选） */
    private String state;

}