package org.dromara.shanheng.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.shanheng.domain.bo.UserAvoidBo;
import org.dromara.shanheng.domain.bo.UserPreferenceBo;
import org.dromara.shanheng.domain.vo.AvoidVo;
import org.dromara.shanheng.domain.vo.PreferenceVo;
import org.dromara.shanheng.service.IAppHealthService;
import org.dromara.shanheng.service.IAppUserService;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * App 用户中心接口（偏好/忌口/隐私）
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/app/v1/user")
public class AppUserController {

    private final IAppUserService userService;
    private final IAppHealthService healthService;

    /** 查询偏好 */
    @GetMapping("/preference")
    public R<PreferenceVo> getPreference() {
        return R.ok(userService.getPreference());
    }

    /** 保存偏好 */
    @PutMapping("/preference")
    public R<PreferenceVo> savePreference(@RequestBody UserPreferenceBo bo) {
        return R.ok(userService.savePreference(bo));
    }

    /** 忌口列表 */
    @GetMapping("/avoid")
    public R<List<AvoidVo>> listAvoid() {
        return R.ok(userService.listAvoid());
    }

    /** 新增忌口 */
    @PostMapping("/avoid")
    public R<AvoidVo> addAvoid(@RequestBody UserAvoidBo bo) {
        return R.ok(userService.addAvoid(bo));
    }

    /** 删除忌口 */
    @DeleteMapping("/avoid/{id}")
    public R<Void> removeAvoid(@PathVariable Long id) {
        userService.removeAvoid(id);
        return R.ok();
    }

    /** 取消健康授权 */
    @PostMapping("/revoke-health-auth")
    public R<Void> revokeHealthAuth() {
        healthService.revokeAuth();
        return R.ok();
    }
}