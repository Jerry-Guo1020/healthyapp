package org.dromara.shanheng.service;

import org.dromara.shanheng.domain.bo.HealthAuthStatusBo;
import org.dromara.shanheng.domain.bo.UploadHealthSummaryBo;
import org.dromara.shanheng.domain.vo.HealthAnalysisVo;
import org.dromara.shanheng.domain.vo.HealthAuthVo;
import org.dromara.shanheng.domain.vo.HealthSummaryVo;

/**
 * App 健康数据服务
 *
 * @author shanheng
 */
public interface IAppHealthService {

    /** 上报/更新健康摘要 */
    void uploadSummary(UploadHealthSummaryBo bo);

    /** 查询最新健康摘要 */
    HealthSummaryVo latest();

    /** 健康分析报告 */
    HealthAnalysisVo analyze();

    /** 更新授权状态 */
    HealthAuthVo updateAuthStatus(HealthAuthStatusBo bo);

    /** 取消健康授权 */
    void revokeAuth();
}