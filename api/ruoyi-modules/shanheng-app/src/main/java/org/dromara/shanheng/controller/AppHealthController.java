package org.dromara.shanheng.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.shanheng.domain.bo.HealthAuthStatusBo;
import org.dromara.shanheng.domain.bo.UploadHealthSummaryBo;
import org.dromara.shanheng.domain.vo.HealthAuthVo;
import org.dromara.shanheng.domain.vo.HealthSummaryVo;
import org.dromara.shanheng.service.IAppHealthService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * App 健康数据接口
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/app/v1/health")
public class AppHealthController {

    private final IAppHealthService healthService;

    /** 上报健康摘要 */
    @PostMapping("/summary")
    public R<Void> uploadSummary(@RequestBody UploadHealthSummaryBo bo) {
        healthService.uploadSummary(bo);
        return R.ok();
    }

    /** 最新健康摘要 */
    @GetMapping("/summary/latest")
    public R<HealthSummaryVo> latest() {
        return R.ok(healthService.latest());
    }

    /** 更新授权状态 */
    @PostMapping("/auth-status")
    public R<HealthAuthVo> authStatus(@RequestBody HealthAuthStatusBo bo) {
        return R.ok(healthService.updateAuthStatus(bo));
    }
}