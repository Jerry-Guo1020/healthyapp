package org.dromara.shanheng.service;

import org.dromara.shanheng.domain.bo.HuaweiLoginBo;
import org.dromara.shanheng.domain.vo.AppLoginVo;

/**
 * App 认证服务接口
 *
 * @author shanheng
 */
public interface IAppAuthService {

    /**
     * 发送验证码
     */
    void sendCode(String phone);

    /**
     * 验证码登录
     */
    AppLoginVo loginByCode(String phone, String code);

    /**
     * 游客登录
     */
    AppLoginVo guestLogin(String deviceId);

    /**
     * 华为账号授权码登录
     */
    AppLoginVo huaweiLogin(HuaweiLoginBo bo);

}