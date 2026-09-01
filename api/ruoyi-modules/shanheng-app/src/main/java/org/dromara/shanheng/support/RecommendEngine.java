package org.dromara.shanheng.support;

import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import org.dromara.shanheng.entity.ShHealthSummary;
import org.dromara.shanheng.entity.ShRecommendationRule;
import org.dromara.shanheng.entity.ShUserAvoid;
import org.dromara.shanheng.entity.ShUserPreference;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 推荐规则引擎：按 sh_recommendation_rule 的 conditions 命中对菜品加减分/排除。
 *
 * 条件支持：
 * - 等值：{"stress_level":3}、{"health_goal":"LOSE_FAT"}
 * - 比较：{"sleep_duration_min":{"lt":360}}
 * - 忌口特殊键：{"avoid":"spicy"}（用户忌口含"辣"即命中）
 *
 * @author shanheng
 */
@Component
public class RecommendEngine {

    /**
     * 执行规则打分
     *
     * @param rules       启用中的规则
     * @param dishTagIds  菜品ID -> 标签ID集合
     * @param summary     健康摘要（可空）
     * @param preference  用户偏好（可空）
     * @param avoidList   用户忌口（可空）
     */
    public Result evaluate(List<ShRecommendationRule> rules,
                           Map<Long, Set<Long>> dishTagIds,
                           ShHealthSummary summary,
                           ShUserPreference preference,
                           List<ShUserAvoid> avoidList) {
        Result result = new Result();
        if (rules == null || rules.isEmpty()) {
            return result;
        }
        for (ShRecommendationRule rule : rules) {
            if (!matches(rule, summary, preference, avoidList)) {
                continue;
            }
            String reason = rule.getReasonTemplate();
            if (StrUtil.isNotBlank(reason)) {
                result.hitReasons.add(reason);
            }
            Long tagId = rule.getTagId();
            if (tagId == null) {
                continue;
            }
            List<Long> targets = new ArrayList<>();
            for (Map.Entry<Long, Set<Long>> entry : dishTagIds.entrySet()) {
                if (entry.getValue().contains(tagId)) {
                    targets.add(entry.getKey());
                }
            }
            String action = rule.getAction();
            int score = rule.getScore() == null ? 0 : rule.getScore();
            for (Long dishId : targets) {
                switch (action) {
                    case "EXCLUDE" -> result.excluded.add(dishId);
                    case "ADD_SCORE" -> {
                        result.scores.merge(dishId, score, Integer::sum);
                        addDishReason(result, dishId, reason);
                    }
                    case "SUB_SCORE" -> result.scores.merge(dishId, -score, Integer::sum);
                    default -> { }
                }
            }
        }
        return result;
    }

    private void addDishReason(Result result, Long dishId, String reason) {
        if (StrUtil.isBlank(reason)) {
            return;
        }
        result.dishReasons.computeIfAbsent(dishId, k -> new ArrayList<>()).add(reason);
    }

    private boolean matches(ShRecommendationRule rule, ShHealthSummary summary,
                            ShUserPreference preference, List<ShUserAvoid> avoidList) {
        String conditions = rule.getConditions();
        if (StrUtil.isBlank(conditions)) {
            return true;
        }
        JSONObject cond;
        try {
            cond = JSONUtil.parseObj(conditions);
        } catch (Exception e) {
            return false;
        }
        for (String key : cond.keySet()) {
            Object expected = cond.get(key);
            Object actual = resolveValue(key, summary, preference, avoidList);
            if (actual == null) {
                return false;
            }
            if (expected instanceof JSONObject) {
                if (!compare((JSONObject) expected, actual)) {
                    return false;
                }
            } else if (!String.valueOf(expected).equals(String.valueOf(actual))) {
                return false;
            }
        }
        return true;
    }

    private Object resolveValue(String key, ShHealthSummary summary,
                                ShUserPreference preference, List<ShUserAvoid> avoidList) {
        if ("avoid".equals(key)) {
            boolean spicy = avoidList != null && avoidList.stream()
                .anyMatch(a -> a.getItemName() != null && a.getItemName().contains("辣"));
            return spicy ? "spicy" : null;
        }
        if ("health_goal".equals(key)) {
            return preference == null ? null : preference.getHealthGoal();
        }
        if (summary == null) {
            return null;
        }
        return switch (key) {
            case "sleep_duration_min" -> summary.getSleepDurationMin();
            case "sleep_quality_score" -> summary.getSleepQualityScore();
            case "resting_heart_rate" -> summary.getRestingHeartRate();
            case "stress_level" -> summary.getStressLevel();
            case "activity_level" -> summary.getActivityLevel();
            case "today_steps" -> summary.getTodaySteps();
            default -> null;
        };
    }

    private boolean compare(JSONObject op, Object actual) {
        if (!(actual instanceof Number num)) {
            return false;
        }
        int value = num.intValue();
        if (op.containsKey("lt") && !(value < op.getInt("lt"))) {
            return false;
        }
        if (op.containsKey("gt") && !(value > op.getInt("gt"))) {
            return false;
        }
        if (op.containsKey("lte") && !(value <= op.getInt("lte"))) {
            return false;
        }
        if (op.containsKey("gte") && !(value >= op.getInt("gte"))) {
            return false;
        }
        if (op.containsKey("eq") && !(value == op.getInt("eq"))) {
            return false;
        }
        return true;
    }

    /** 规则执行结果 */
    public static class Result {
        /** 菜品ID -> 得分 */
        public final Map<Long, Integer> scores = new HashMap<>();
        /** 被排除的菜品ID */
        public final Set<Long> excluded = new HashSet<>();
        /** 命中的规则理由（全局） */
        public final List<String> hitReasons = new ArrayList<>();
        /** 菜品ID -> 命中的规则理由列表 */
        public final Map<Long, List<String>> dishReasons = new HashMap<>();
    }
}