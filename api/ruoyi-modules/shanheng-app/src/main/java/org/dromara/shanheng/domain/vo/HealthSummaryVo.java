package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 健康摘要视图
 *
 * @author shanheng
 */
@Data
public class HealthSummaryVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** ID */
    private Long id;

    /** 摘要日期 yyyy-MM-dd */
    private String summaryDate;

    /** 今日步数 */
    private Integer todaySteps;

    /** 睡眠时长(分钟) */
    private Integer sleepDurationMin;

    /** 睡眠质量评分0-100 */
    private Integer sleepQualityScore;

    /** 静息心率(bpm) */
    private Integer restingHeartRate;

    /** 压力等级 1低 2中 3高 */
    private Integer stressLevel;

    /** 活动量 1低 2中 3高 */
    private Integer activityLevel;

    /** 来源 HEALTH_KIT/MANUAL */
    private String source;

    /** 数据采集时间 */
    private String dataTime;
}