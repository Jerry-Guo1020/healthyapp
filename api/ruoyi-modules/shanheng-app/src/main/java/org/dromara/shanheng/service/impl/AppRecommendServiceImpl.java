package org.dromara.shanheng.service.impl;

import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.shanheng.domain.bo.RecommendBo;
import org.dromara.shanheng.domain.bo.RecommendFeedbackBo;
import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.domain.vo.RecommendItemVo;
import org.dromara.shanheng.domain.vo.RecommendResultVo;
import org.dromara.shanheng.domain.vo.RecommendationRecordVo;
import org.dromara.shanheng.entity.ShDish;
import org.dromara.shanheng.entity.ShDishTag;
import org.dromara.shanheng.entity.ShHealthSummary;
import org.dromara.shanheng.entity.ShRecommendFeedback;
import org.dromara.shanheng.entity.ShRecommendationRecord;
import org.dromara.shanheng.entity.ShRecommendationRule;
import org.dromara.shanheng.entity.ShTag;
import org.dromara.shanheng.entity.ShUserAvoid;
import org.dromara.shanheng.entity.ShUserPreference;
import org.dromara.shanheng.mapper.ShDishMapper;
import org.dromara.shanheng.mapper.ShDishTagMapper;
import org.dromara.shanheng.mapper.ShHealthSummaryMapper;
import org.dromara.shanheng.mapper.ShRecommendFeedbackMapper;
import org.dromara.shanheng.mapper.ShRecommendationRecordMapper;
import org.dromara.shanheng.mapper.ShRecommendationRuleMapper;
import org.dromara.shanheng.mapper.ShTagMapper;
import org.dromara.shanheng.mapper.ShUserAvoidMapper;
import org.dromara.shanheng.mapper.ShUserPreferenceMapper;
import org.dromara.shanheng.service.IAppRecommendService;
import org.dromara.shanheng.support.DishAssembler;
import org.dromara.shanheng.support.HealthSummaryAssembler;
import org.dromara.shanheng.support.RecommendEngine;
import org.dromara.shanheng.util.AppLoginHelper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * App 智能推荐服务实现
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@Service
public class AppRecommendServiceImpl implements IAppRecommendService {

    private static final int TOP_N = 6;

    private final ShDishMapper dishMapper;
    private final ShDishTagMapper dishTagMapper;
    private final ShTagMapper tagMapper;
    private final ShHealthSummaryMapper healthSummaryMapper;
    private final ShUserPreferenceMapper preferenceMapper;
    private final ShUserAvoidMapper avoidMapper;
    private final ShRecommendationRuleMapper ruleMapper;
    private final ShRecommendationRecordMapper recordMapper;
    private final ShRecommendFeedbackMapper feedbackMapper;
    private final DishAssembler dishAssembler;
    private final HealthSummaryAssembler healthSummaryAssembler;
    private final RecommendEngine recommendEngine;

    @Override
    public RecommendResultVo recommend(RecommendBo bo) {
        Long userId = requireUserId();

        ShUserPreference preference = preferenceMapper.selectOne(new LambdaQueryWrapper<ShUserPreference>()
            .eq(ShUserPreference::getUserId, userId).last("limit 1"));
        List<ShUserAvoid> avoidList = avoidMapper.selectList(new LambdaQueryWrapper<ShUserAvoid>()
            .eq(ShUserAvoid::getUserId, userId));

        ShHealthSummary summary = null;
        if (Boolean.TRUE.equals(bo.getUseHealthData())) {
            summary = healthSummaryMapper.selectOne(new LambdaQueryWrapper<ShHealthSummary>()
                .eq(ShHealthSummary::getUserId, userId)
                .orderByDesc(ShHealthSummary::getSummaryDate)
                .orderByDesc(ShHealthSummary::getId)
                .last("limit 1"));
        }

        // 候选菜品：上架 + 分类 + 预算
        LambdaQueryWrapper<ShDish> wrapper = new LambdaQueryWrapper<ShDish>()
            .eq(ShDish::getStatus, 1);
        if (bo.getCategoryIds() != null && !bo.getCategoryIds().isEmpty()) {
            wrapper.in(ShDish::getCategoryId, bo.getCategoryIds());
        }
        if (bo.getBudgetMin() != null) {
            wrapper.ge(ShDish::getPriceMax, bo.getBudgetMin());
        }
        if (bo.getBudgetMax() != null) {
            wrapper.le(ShDish::getPriceMin, bo.getBudgetMax());
        }
        List<ShDish> candidates = dishMapper.selectList(wrapper);

        RecommendResultVo result = new RecommendResultVo();
        result.setHealthSummary(healthSummaryAssembler.toVo(summary));
        result.setTodayReminder(buildReminder(summary));
        result.setRecordId(null);

        if (candidates.isEmpty()) {
            result.setRecommendations(Collections.emptyList());
            return result;
        }

        List<Long> candidateIds = candidates.stream().map(ShDish::getId).collect(Collectors.toList());
        Map<Long, Set<Long>> dishTagIds = loadDishTagIds(candidateIds);
        List<ShTag> tags = tagMapper.selectList(null);

        // 忌口硬过滤
        Set<Long> excluded = new HashSet<>();
        applyAvoidFilter(candidates, dishTagIds, tags, avoidList, excluded);

        // 规则引擎
        List<ShRecommendationRule> rules = ruleMapper.selectList(new LambdaQueryWrapper<ShRecommendationRule>()
            .eq(ShRecommendationRule::getStatus, 1)
            .orderByAsc(ShRecommendationRule::getPriority));
        RecommendEngine.Result engineResult = recommendEngine.evaluate(rules, dishTagIds, summary, preference, avoidList);
        excluded.addAll(engineResult.excluded);

        // 打分排序（未排除的按得分降序，平分按 id 降序）
        List<Long> ordered = candidateIds.stream()
            .filter(id -> !excluded.contains(id))
            .sorted((a, b) -> {
                int sa = engineResult.scores.getOrDefault(a, 0);
                int sb = engineResult.scores.getOrDefault(b, 0);
                if (sa != sb) {
                    return sb - sa;
                }
                return Long.compare(b, a);
            })
            .collect(Collectors.toList());

        List<Long> topIds = ordered.stream().limit(TOP_N).collect(Collectors.toList());
        Map<Long, ShDish> dishMap = candidates.stream()
            .collect(Collectors.toMap(ShDish::getId, d -> d, (a, b) -> a));
        Map<Long, DishVo> dishVoMap = dishAssembler.assemble(
                topIds.stream().map(dishMap::get).filter(java.util.Objects::nonNull).collect(Collectors.toList()))
            .stream().collect(Collectors.toMap(DishVo::getId, v -> v, (a, b) -> a));

        List<RecommendItemVo> items = new ArrayList<>();
        for (Long id : topIds) {
            DishVo vo = dishVoMap.get(id);
            if (vo == null) {
                continue;
            }
            RecommendItemVo item = new RecommendItemVo();
            item.setDish(vo);
            item.setScore(engineResult.scores.getOrDefault(id, 0));
            item.setReason(buildReason(id, engineResult));
            item.setHealthAdvice(buildHealthAdvice(summary));
            items.add(item);
        }
        result.setRecommendations(items);

        // 写推荐记录
        ShRecommendationRecord record = new ShRecommendationRecord();
        record.setUserId(userId);
        record.setScene(bo.getScene());
        record.setDishIds(topIds.stream().map(String::valueOf).collect(Collectors.joining(",")));
        record.setReason(items.isEmpty() ? "" : items.get(0).getReason());
        JSONObject snapshot = new JSONObject();
        snapshot.set("scene", bo.getScene());
        snapshot.set("categoryIds", bo.getCategoryIds());
        snapshot.set("budgetMin", bo.getBudgetMin());
        snapshot.set("budgetMax", bo.getBudgetMax());
        snapshot.set("useHealthData", bo.getUseHealthData());
        record.setInputSnapshot(snapshot.toString());
        recordMapper.insert(record);
        result.setRecordId(record.getId());
        return result;
    }

    @Override
    public AppPageVo<RecommendationRecordVo> history(Integer pageNum, Integer pageSize) {
        Long userId = requireUserId();
        Page<ShRecommendationRecord> page = recordMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<ShRecommendationRecord>()
                .eq(ShRecommendationRecord::getUserId, userId)
                .orderByDesc(ShRecommendationRecord::getId));
        List<RecommendationRecordVo> list = page.getRecords().stream().map(r -> {
            RecommendationRecordVo vo = new RecommendationRecordVo();
            vo.setId(r.getId());
            vo.setScene(r.getScene());
            vo.setDishIds(r.getDishIds());
            vo.setReason(r.getReason());
            vo.setCreateTime(r.getCreateTime() == null ? null : DateUtil.formatDateTime(r.getCreateTime()));
            return vo;
        }).collect(Collectors.toList());
        return AppPageVo.of(page, list);
    }

    @Override
    public void feedback(Long recordId, RecommendFeedbackBo bo) {
        Long userId = requireUserId();
        ShRecommendationRecord record = recordMapper.selectById(recordId);
        if (record == null || !userId.equals(record.getUserId())) {
            throw new ServiceException("推荐记录不存在");
        }
        ShRecommendFeedback feedback = new ShRecommendFeedback();
        feedback.setRecordId(recordId);
        feedback.setUserId(userId);
        feedback.setDishId(bo.getDishId());
        feedback.setFeedbackType(bo.getFeedbackType());
        feedback.setReason(bo.getReason());
        feedbackMapper.insert(feedback);
    }

    private Map<Long, Set<Long>> loadDishTagIds(List<Long> dishIds) {
        Map<Long, Set<Long>> map = new HashMap<>();
        if (dishIds.isEmpty()) {
            return map;
        }
        List<ShDishTag> relations = dishTagMapper.selectList(new LambdaQueryWrapper<ShDishTag>()
            .in(ShDishTag::getDishId, dishIds));
        for (ShDishTag relation : relations) {
            map.computeIfAbsent(relation.getDishId(), k -> new HashSet<>()).add(relation.getTagId());
        }
        return map;
    }

    private void applyAvoidFilter(List<ShDish> candidates, Map<Long, Set<Long>> dishTagIds,
                                  List<ShTag> tags, List<ShUserAvoid> avoidList, Set<Long> excluded) {
        if (avoidList == null || avoidList.isEmpty() || tags == null || tags.isEmpty()) {
            return;
        }
        for (ShUserAvoid avoid : avoidList) {
            String item = avoid.getItemName();
            if (StrUtil.isBlank(item)) {
                continue;
            }
            // 忌口项命中标签名（如"辣椒" → 标签"辣味"）
            for (ShTag tag : tags) {
                if (tag.getName().contains(item) || item.contains(tag.getName())) {
                    Long tagId = tag.getId();
                    for (ShDish d : candidates) {
                        Set<Long> dishTags = dishTagIds.get(d.getId());
                        if (dishTags != null && dishTags.contains(tagId)) {
                            excluded.add(d.getId());
                        }
                    }
                }
            }
            // 忌口项命中食材清单
            for (ShDish d : candidates) {
                String ingredients = d.getIngredients();
                if (ingredients != null && ingredients.contains(item)) {
                    excluded.add(d.getId());
                }
            }
        }
    }

    private String buildReason(Long dishId, RecommendEngine.Result engineResult) {
        List<String> reasons = engineResult.dishReasons.get(dishId);
        if (reasons != null && !reasons.isEmpty()) {
            return reasons.stream().distinct().collect(Collectors.joining("；"));
        }
        if (!engineResult.hitReasons.isEmpty()) {
            return engineResult.hitReasons.get(0);
        }
        return "为你精选的健康餐品";
    }

    private String buildHealthAdvice(ShHealthSummary s) {
        if (s == null) {
            return "保持均衡饮食，多吃蔬果，少油少盐";
        }
        List<String> advices = new ArrayList<>();
        if (s.getSleepDurationMin() != null && s.getSleepDurationMin() < 360) {
            advices.add("建议保证 7 小时睡眠");
        }
        if (s.getStressLevel() != null && s.getStressLevel() >= 3) {
            advices.add("压力偏高，注意放松身心");
        }
        if (s.getTodaySteps() != null && s.getTodaySteps() > 10000) {
            advices.add("活动量大，注意补充水分与蛋白质");
        }
        return advices.isEmpty() ? "状态不错，保持均衡饮食" : String.join("；", advices);
    }

    private String buildReminder(ShHealthSummary s) {
        if (s == null) {
            return "完善健康数据，可获得更精准的推荐";
        }
        if (s.getTodaySteps() != null && s.getTodaySteps() < 3000) {
            return "今日步数偏低，建议餐后散步 20 分钟";
        }
        if (s.getSleepDurationMin() != null && s.getSleepDurationMin() < 360) {
            return "昨晚睡眠不足，今晚早点休息";
        }
        return "保持均衡饮食，记得多喝水";
    }

    private Long requireUserId() {
        Long userId = AppLoginHelper.getUserId();
        if (userId == null) {
            throw new ServiceException("请先登录");
        }
        return userId;
    }
}