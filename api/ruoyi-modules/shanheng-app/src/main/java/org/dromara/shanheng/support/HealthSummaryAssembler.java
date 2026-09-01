package org.dromara.shanheng.support;

import cn.hutool.core.date.DateUtil;
import org.dromara.shanheng.domain.vo.HealthSummaryVo;
import org.dromara.shanheng.entity.ShHealthSummary;
import org.springframework.stereotype.Component;

/**
 * 健康摘要视图装配器
 *
 * @author shanheng
 */
@Component
public class HealthSummaryAssembler {

    public HealthSummaryVo toVo(ShHealthSummary s) {
        if (s == null) {
            return null;
        }
        HealthSummaryVo vo = new HealthSummaryVo();
        vo.setId(s.getId());
        vo.setSummaryDate(s.getSummaryDate() == null ? null : DateUtil.formatDate(s.getSummaryDate()));
        vo.setTodaySteps(s.getTodaySteps());
        vo.setSleepDurationMin(s.getSleepDurationMin());
        vo.setSleepQualityScore(s.getSleepQualityScore());
        vo.setRestingHeartRate(s.getRestingHeartRate());
        vo.setStressLevel(s.getStressLevel());
        vo.setActivityLevel(s.getActivityLevel());
        vo.setSource(s.getSource());
        vo.setDataTime(s.getDataTime() == null ? null : DateUtil.formatDateTime(s.getDataTime()));
        return vo;
    }
}