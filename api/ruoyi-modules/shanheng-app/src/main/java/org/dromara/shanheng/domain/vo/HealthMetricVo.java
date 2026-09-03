package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 健康分析单指标项（用于 App 卡片式展示）
 *
 * @author shanheng
 */
@Data
public class HealthMetricVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 指标键 steps/sleep/heartRate/stress/activity */
    private String key;

    /** 图标（emoji） */
    private String icon;

    /** 指标名称 */
    private String label;

    /** 展示值 */
    private String value;

    /** 单位 */
    private String unit;

    /** 等级 1优秀 2良好 3一般 4需关注 */
    private Integer level;

    /** 等级文字 */
    private String levelText;

    /** 个性化建议 */
    private String advice;

    /** 进度条 0-100（无进度的指标给默认值） */
    private Integer progress;

    /** 单指标得分 0-100 */
    private Integer score;
}