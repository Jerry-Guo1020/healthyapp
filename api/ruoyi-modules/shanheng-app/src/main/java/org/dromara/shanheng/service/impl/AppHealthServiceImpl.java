package org.dromara.shanheng.service.impl;

import cn.hutool.core.date.DateUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.shanheng.domain.bo.HealthAuthStatusBo;
import org.dromara.shanheng.domain.bo.RecommendBo;
import org.dromara.shanheng.domain.bo.UploadHealthSummaryBo;
import org.dromara.shanheng.domain.vo.HealthAnalysisVo;
import org.dromara.shanheng.domain.vo.HealthAuthVo;
import org.dromara.shanheng.domain.vo.HealthSummaryVo;
import org.dromara.shanheng.domain.vo.RecommendResultVo;
import org.dromara.shanheng.entity.ShHealthAuth;
import org.dromara.shanheng.entity.ShHealthSummary;
import org.dromara.shanheng.mapper.ShHealthAuthMapper;
import org.dromara.shanheng.mapper.ShHealthSummaryMapper;
import org.dromara.shanheng.service.IAppHealthService;
import org.dromara.shanheng.service.IAppRecommendService;
import org.dromara.shanheng.support.HealthAnalyzer;
import org.dromara.shanheng.support.HealthSummaryAssembler;
import org.dromara.shanheng.util.AppLoginHelper;
import org.springframework.stereotype.Service;

import java.util.Date;

/**
 * App 健康数据服务实现
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@Service
public class AppHealthServiceImpl implements IAppHealthService {

    private final ShHealthSummaryMapper healthSummaryMapper;
    private final ShHealthAuthMapper healthAuthMapper;
    private final HealthSummaryAssembler healthSummaryAssembler;
    private final HealthAnalyzer healthAnalyzer;
    private final IAppRecommendService recommendService;

    @Override
    public void uploadSummary(UploadHealthSummaryBo bo) {
        Long userId = requireUserId();
        String summaryDate = StrUtil.isBlank(bo.getSummaryDate()) ? DateUtil.today() : bo.getSummaryDate();

        ShHealthSummary existing = healthSummaryMapper.selectOne(new LambdaQueryWrapper<ShHealthSummary>()
            .eq(ShHealthSummary::getUserId, userId)
            .apply("summary_date = {0}", summaryDate)
            .last("limit 1"));

        if (existing == null) {
            existing = new ShHealthSummary();
            existing.setUserId(userId);
            existing.setSummaryDate(DateUtil.parseDate(summaryDate));
            healthSummaryMapper.insert(existing);
        }
        existing.setTodaySteps(bo.getTodaySteps());
        existing.setSleepDurationMin(bo.getSleepDurationMin());
        existing.setSleepQualityScore(bo.getSleepQualityScore());
        existing.setRestingHeartRate(bo.getRestingHeartRate());
        existing.setStressLevel(bo.getStressLevel());
        existing.setActivityLevel(bo.getActivityLevel());
        existing.setSource(StrUtil.blankToDefault(bo.getSource(), "MANUAL"));
        existing.setDataTime(StrUtil.isBlank(bo.getDataTime()) ? new Date() : DateUtil.parse(bo.getDataTime()));
        healthSummaryMapper.updateById(existing);
    }

    @Override
    public HealthSummaryVo latest() {
        Long userId = requireUserId();
        ShHealthSummary s = healthSummaryMapper.selectOne(new LambdaQueryWrapper<ShHealthSummary>()
            .eq(ShHealthSummary::getUserId, userId)
            .orderByDesc(ShHealthSummary::getSummaryDate)
            .orderByDesc(ShHealthSummary::getId)
            .last("limit 1"));
        return healthSummaryAssembler.toVo(s);
    }

    @Override
    public HealthAnalysisVo analyze() {
        Long userId = requireUserId();
        ShHealthSummary summary = healthSummaryMapper.selectOne(new LambdaQueryWrapper<ShHealthSummary>()
            .eq(ShHealthSummary::getUserId, userId)
            .orderByDesc(ShHealthSummary::getSummaryDate)
            .orderByDesc(ShHealthSummary::getId)
            .last("limit 1"));

        HealthAnalysisVo analysis = healthAnalyzer.analyze(summary);
        if (Boolean.TRUE.equals(analysis.getHasData())) {
            RecommendBo bo = new RecommendBo();
            bo.setScene("HEALTH_ANALYSIS");
            bo.setUseHealthData(true);
            RecommendResultVo rec = recommendService.recommend(bo);
            analysis.setRecommendations(rec.getRecommendations());
            analysis.setTodayReminder(rec.getTodayReminder());
        }
        return analysis;
    }

    @Override
    public HealthAuthVo updateAuthStatus(HealthAuthStatusBo bo) {
        Long userId = requireUserId();
        Date now = new Date();
        // 旧授权记录置失效
        healthAuthMapper.update(null, new LambdaUpdateWrapper<ShHealthAuth>()
            .eq(ShHealthAuth::getUserId, userId)
            .eq(ShHealthAuth::getStatus, 1)
            .set(ShHealthAuth::getStatus, 0)
            .set(ShHealthAuth::getRevokeTime, now));

        ShHealthAuth auth = new ShHealthAuth();
        auth.setUserId(userId);
        auth.setAuthScope(bo.getAuthScope() == null ? null : JSONUtil.toJsonStr(bo.getAuthScope()));
        auth.setStatus(1);
        auth.setAuthorizeTime(now);
        healthAuthMapper.insert(auth);

        HealthAuthVo vo = new HealthAuthVo();
        vo.setAuthScope(bo.getAuthScope());
        vo.setStatus(1);
        vo.setAuthorizeTime(DateUtil.formatDateTime(now));
        return vo;
    }

    @Override
    public void revokeAuth() {
        Long userId = requireUserId();
        healthAuthMapper.update(null, new LambdaUpdateWrapper<ShHealthAuth>()
            .eq(ShHealthAuth::getUserId, userId)
            .eq(ShHealthAuth::getStatus, 1)
            .set(ShHealthAuth::getStatus, 0)
            .set(ShHealthAuth::getRevokeTime, new Date()));
    }

    private Long requireUserId() {
        Long userId = AppLoginHelper.getUserId();
        if (userId == null) {
            throw new ServiceException("请先登录");
        }
        return userId;
    }
}