package org.dromara.shanheng.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.shanheng.domain.bo.GuestLoginBo;
import org.dromara.shanheng.domain.bo.HuaweiLoginBo;
import org.dromara.shanheng.domain.bo.LoginByCodeBo;
import org.dromara.shanheng.domain.bo.SendCodeBo;
import org.dromara.shanheng.domain.vo.AppLoginVo;
import org.dromara.shanheng.service.IAppAuthService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * App 认证接口
 *
 * @author shanheng
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/app/v1/auth")
public class AppAuthController {

    private final IAppAuthService appAuthService;

    /**
     * 发送验证码
     */
    @PostMapping("/send-code")
    public R<Void> sendCode(@Validated @RequestBody SendCodeBo bo) {
        appAuthService.sendCode(bo.getPhone());
        return R.ok();
    }

    /**
     * 验证码登录
     */
    @PostMapping("/login-by-code")
    public R<AppLoginVo> loginByCode(@Validated @RequestBody LoginByCodeBo bo) {
        return R.ok(appAuthService.loginByCode(bo.getPhone(), bo.getCode()));
    }

    /**
     * 游客登录
     */
    @PostMapping("/guest")
    public R<AppLoginVo> guest(@Validated @RequestBody GuestLoginBo bo) {
        return R.ok(appAuthService.guestLogin(bo.getDeviceId()));
    }

    /**
     * 华为账号授权码登录
     */
    @PostMapping("/huawei-login")
    public R<AppLoginVo> huaweiLogin(@Validated @RequestBody HuaweiLoginBo bo) {
        return R.ok(appAuthService.huaweiLogin(bo));
    }

    /**
     * 登出（无状态 JWT，客户端丢弃 Token 即可）
     */
    @PostMapping("/logout")
    public R<Void> logout() {
        return R.ok();
    }

}