package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * 用户健康摘要对象 sh_health_summary（只存摘要，不存原始数据）
 *
 * @author shanheng
 */
@Data
@TableName("sh_health_summary")
public class ShHealthSummary implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id")
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 摘要日期 */
    private Date summaryDate;

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
    private Date dataTime;

    /** 创建时间 */
    private Date createTime;

}
