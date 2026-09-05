package org.dromara.shanheng.domain.bo;

import lombok.Data;

/**
 * 华为账号登录请求体。
 * <p>
 * 支持三种模式（优先级：authorizationCode > code > unionId）：
 * <ul>
 *   <li>华为账号一键登录（LoginWithHuaweiIDButton 组件）：传 {@code authorizationCode}，
 *       后端用授权码调 {@code /oauth2/v6/quickLogin/getPhoneNumber} 换取完整手机号 + UnionID/OpenID。</li>
 *   <li>普通华为账号登录（openid + profile 授权码模式）：只传 {@code code}，
 *       后端用 code 换取 access_token 再读用户信息（UnionID/OpenID/昵称/头像/手机号）。</li>
 *   <li>兼容旧版直登：组件回调直接传 {@code unionId}/{@code openId}，无需换 token。</li>
 * </ul>
 *
 * @author shanheng
 */
@Data
public class HuaweiLoginBo {

    /** 一键登录授权码（LoginWithHuaweiIDButton 组件回调返回的 authorizationCode） */
    private String authorizationCode;

    /** 华为授权码（普通华为账号登录） */
    private String code;

    /** UnionID（一键登录组件回调返回） */
    private String unionId;

    /** OpenID（一键登录组件回调返回，可选） */
    private String openId;

    /** 昵称（可选，组件返回时透传） */
    private String nickname;

    /** 头像（可选，组件返回时透传） */
    private String avatarUrl;

    /** 状态位（原样回传，防 CSRF，可选） */
    private String state;

}