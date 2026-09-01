package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

/**
 * 推荐结果视图
 *
 * @author shanheng
 */
@Data
public class RecommendResultVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 推荐记录ID */
    private Long recordId;

    /** 推荐列表 */
    private List<RecommendItemVo> recommendations;

    /** 今日提醒 */
    private String todayReminder;

    /** 本次参与推荐的健康摘要（可能为 null） */
    private HealthSummaryVo healthSummary;
}