package org.dromara.shanheng.service;

import org.dromara.shanheng.domain.bo.RecommendBo;
import org.dromara.shanheng.domain.bo.RecommendFeedbackBo;
import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.RecommendResultVo;
import org.dromara.shanheng.domain.vo.RecommendationRecordVo;

/**
 * App 智能推荐服务
 *
 * @author shanheng
 */
public interface IAppRecommendService {

    /** 生成推荐 */
    RecommendResultVo recommend(RecommendBo bo);

    /** 推荐历史 */
    AppPageVo<RecommendationRecordVo> history(Integer pageNum, Integer pageSize);

    /** 推荐反馈 */
    void feedback(Long recordId, RecommendFeedbackBo bo);
}