package org.dromara.shanheng.support;

import org.dromara.shanheng.domain.vo.HealthAnalysisVo;
import org.dromara.shanheng.domain.vo.HealthMetricVo;
import org.dromara.shanheng.entity.ShHealthSummary;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * 健康分析引擎：把健康摘要拆成逐项指标卡 + 评分 + 结论 + 饮食建议。
 * 纯逻辑无副作用，供「健康」页分析接口与后续 Health Kit 数据透出共用。
 *
 * @author shanheng
 */
@Component
public class HealthAnalyzer {

    /** 分析健康摘要，返回结构化报告 */
    public HealthAnalysisVo analyze(ShHealthSummary s) {
        HealthAnalysisVo vo = new HealthAnalysisVo();
        if (s == null) {
            vo.setHasData(false);
            vo.setSummary("记录健康数据后，可生成个性化健康分析与饮食建议");
            return vo;
        }

        List<HealthMetricVo> metrics = new ArrayList<>();
        if (s.getTodaySteps() != null) {
            metrics.add(analyzeSteps(s.getTodaySteps()));
        }
        if (s.getSleepDurationMin() != null) {
            metrics.add(analyzeSleep(s.getSleepDurationMin()));
        }
        if (s.getRestingHeartRate() != null) {
            metrics.add(analyzeHeartRate(s.getRestingHeartRate()));
        }
        if (s.getStressLevel() != null) {
            metrics.add(analyzeStress(s.getStressLevel()));
        }
        if (s.getActivityLevel() != null) {
            metrics.add(analyzeActivity(s.getActivityLevel()));
        }

        if (metrics.isEmpty()) {
            vo.setHasData(false);
            vo.setSummary("暂无有效健康数据，请先记录或同步华为运动健康");
            return vo;
        }

        int total = (int) Math.round(metrics.stream().mapToInt(HealthMetricVo::getScore).average().orElse(0));
        vo.setHasData(true);
        vo.setMetrics(metrics);
        vo.setTotalScore(total);
        vo.setTotalLevel(totalLevel(total));
        vo.setSummary(buildSummary(total));
        vo.setDietAdvice(buildDietAdvice(metrics));
        return vo;
    }

    private HealthMetricVo analyzeSteps(int steps) {
        HealthMetricVo m = base("steps", "👟", "今日步数", String.valueOf(steps), "步");
        m.setProgress(Math.min(steps * 100 / 10000, 100));
        if (steps < 4000) {
            fill(m, 4, 40, "久坐较多，建议每天散步 30 分钟");
        } else if (steps < 6000) {
            fill(m, 3, 60, "适当增加日常步数，目标 8000 步");
        } else if (steps < 8000) {
            fill(m, 2, 75, "活动量良好，继续保持");
        } else if (steps < 10000) {
            fill(m, 2, 85, "活动量充足，状态很棒");
        } else {
            fill(m, 1, 95, "活动量优秀，注意补充水分与蛋白质");
        }
        return m;
    }

    private HealthMetricVo analyzeSleep(int min) {
        HealthMetricVo m = base("sleep", "😴", "昨晚睡眠", hours(min), "小时");
        m.setProgress(Math.min(min * 100 / 540, 100));
        if (min < 360) {
            fill(m, 4, 40, "睡眠不足，建议保证 7 小时以上");
        } else if (min < 420) {
            fill(m, 3, 60, "睡眠略少，尽量提前入睡");
        } else if (min < 540) {
            fill(m, 2, 80, "睡眠时长良好");
        } else {
            fill(m, 1, 95, "睡眠充足，状态极佳");
        }
        return m;
    }

    private HealthMetricVo analyzeHeartRate(int hr) {
        HealthMetricVo m = base("heartRate", "❤️", "静息心率", String.valueOf(hr), "bpm");
        m.setProgress(70);
        if (hr >= 55 && hr <= 70) {
            fill(m, 1, 90, "静息心率优秀，心肺状态好");
        } else if (hr >= 50 && hr <= 80) {
            fill(m, 2, 80, "静息心率正常");
        } else if (hr > 80 && hr <= 100) {
            fill(m, 3, 65, "静息心率偏高，注意减压与有氧运动");
        } else {
            fill(m, 4, 50, "静息心率异常，建议关注心血管健康");
        }
        return m;
    }

    private HealthMetricVo analyzeStress(int level) {
        HealthMetricVo m = base("stress", "🧘", "压力水平", "", "");
        if (level == 1) {
            m.setValue("低");
            m.setProgress(90);
            fill(m, 1, 90, "压力较低，身心放松");
        } else if (level == 2) {
            m.setValue("中");
            m.setProgress(60);
            fill(m, 2, 75, "压力适中，注意劳逸结合");
        } else {
            m.setValue("高");
            m.setProgress(30);
            fill(m, 4, 50, "压力偏高，建议多休息、适当冥想");
        }
        return m;
    }

    private HealthMetricVo analyzeActivity(int level) {
        HealthMetricVo m = base("activity", "🏃", "活动量", "", "");
        if (level == 1) {
            m.setValue("较少");
            m.setProgress(40);
            fill(m, 3, 55, "活动偏少，建议增加中等强度运动");
        } else if (level == 2) {
            m.setValue("适中");
            m.setProgress(65);
            fill(m, 2, 75, "活动量适中，保持");
        } else {
            m.setValue("充足");
            m.setProgress(95);
            fill(m, 1, 90, "活动量充足，注意补充能量");
        }
        return m;
    }

    private HealthMetricVo base(String key, String icon, String label, String value, String unit) {
        HealthMetricVo m = new HealthMetricVo();
        m.setKey(key);
        m.setIcon(icon);
        m.setLabel(label);
        m.setValue(value);
        m.setUnit(unit);
        return m;
    }

    private void fill(HealthMetricVo m, int level, int score, String advice) {
        m.setLevel(level);
        m.setLevelText(metricLevelText(level));
        m.setScore(score);
        m.setAdvice(advice);
    }

    private String metricLevelText(int level) {
        return switch (level) {
            case 1 -> "优秀";
            case 2 -> "良好";
            case 3 -> "一般";
            default -> "需关注";
        };
    }

    private String totalLevel(int score) {
        if (score >= 85) {
            return "优秀";
        }
        if (score >= 70) {
            return "良好";
        }
        if (score >= 55) {
            return "一般";
        }
        return "需关注";
    }

    private String buildSummary(int total) {
        if (total >= 85) {
            return "整体状态优秀，继续保持健康的生活方式";
        }
        if (total >= 70) {
            return "整体状态良好，个别指标仍有提升空间";
        }
        if (total >= 55) {
            return "整体状态一般，建议关注偏弱指标并逐步改善";
        }
        return "多项指标偏弱，建议尽快调整作息与饮食";
    }

    private String buildDietAdvice(List<HealthMetricVo> metrics) {
        Set<String> advices = new LinkedHashSet<>();
        for (HealthMetricVo m : metrics) {
            if (m.getLevel() != null && m.getLevel() >= 3) {
                String d = dietAdviceFor(m.getKey());
                if (d != null) {
                    advices.add(d);
                }
            }
        }
        if (advices.isEmpty()) {
            return "各项指标良好，保持均衡饮食，多吃蔬果，少油少盐";
        }
        return String.join("；", advices);
    }

    private String dietAdviceFor(String key) {
        return switch (key) {
            case "steps" -> "活动偏少，控制主食份量，多摄入膳食纤维（燕麦、糙米、绿叶菜）";
            case "sleep" -> "睡眠不足，午后避免咖啡因，晚餐清淡易消化，可吃香蕉、小米粥助眠";
            case "heartRate" -> "静息心率偏高，少油少盐，多吃深海鱼、坚果与全谷物";
            case "stress" -> "压力偏高，多吃富含镁与 B 族维生素的食物（坚果、深绿蔬菜、全谷物）";
            case "activity" -> "活动量少，控制总热量，提高优质蛋白与蔬菜比例";
            default -> null;
        };
    }

    private String hours(int min) {
        int h = min / 60;
        int tenth = (min % 60) * 10 / 60;
        if (tenth == 0) {
            return String.valueOf(h);
        }
        return h + "." + tenth;
    }
}