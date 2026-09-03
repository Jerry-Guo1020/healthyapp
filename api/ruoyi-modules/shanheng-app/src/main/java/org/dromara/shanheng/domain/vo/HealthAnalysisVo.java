package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

/**
 * 健康分析报告（App「健康」页卡片式展示）
 *
 * @author shanheng
 */
@Data
public class HealthAnalysisVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 是否有健康数据 */
    private Boolean hasData;

    /** 综合评分 0-100 */
    private Integer totalScore;

    /** 综合评级 优秀/良好/一般/需关注 */
    private String totalLevel;

    /** 一句话综合结论 */
    private String summary;

    /** 饮食建议 */
    private String dietAdvice;

    /** 逐项指标 */
    private List<HealthMetricVo> metrics;

    /** 关联推荐（复用智能推荐） */
    private List<RecommendItemVo> recommendations;

    /** 今日提醒 */
    private String todayReminder;
}