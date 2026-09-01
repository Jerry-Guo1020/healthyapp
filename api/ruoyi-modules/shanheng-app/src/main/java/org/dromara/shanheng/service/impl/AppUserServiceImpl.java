package org.dromara.shanheng.service.impl;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.shanheng.domain.bo.UserAvoidBo;
import org.dromara.shanheng.domain.bo.UserPreferenceBo;
import org.dromara.shanheng.domain.vo.AvoidVo;
import org.dromara.shanheng.domain.vo.PreferenceVo;
import org.dromara.shanheng.entity.ShUserAvoid;
import org.dromara.shanheng.entity.ShUserPreference;
import org.dromara.shanheng.mapper.ShUserAvoidMapper;
import org.dromara.shanheng.mapper.ShUserPreferenceMapper;
import org.dromara.shanheng.service.IAppUserService;
import org.dromara.shanheng.util.AppLoginHelper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * App 用户中心服务实现（偏好/忌口）
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@Service
public class AppUserServiceImpl implements IAppUserService {

    private final ShUserPreferenceMapper preferenceMapper;
    private final ShUserAvoidMapper avoidMapper;

    @Override
    public PreferenceVo getPreference() {
        Long userId = requireUserId();
        ShUserPreference p = preferenceMapper.selectOne(new LambdaQueryWrapper<ShUserPreference>()
            .eq(ShUserPreference::getUserId, userId)
            .last("limit 1"));
        return toVo(p);
    }

    @Override
    public PreferenceVo savePreference(UserPreferenceBo bo) {
        Long userId = requireUserId();
        ShUserPreference p = preferenceMapper.selectOne(new LambdaQueryWrapper<ShUserPreference>()
            .eq(ShUserPreference::getUserId, userId)
            .last("limit 1"));
        if (p == null) {
            p = new ShUserPreference();
            p.setUserId(userId);
            p.setTastePreference(bo.getTastePreference());
            p.setCuisinePreference(bo.getCuisinePreference());
            p.setBudgetMin(bo.getBudgetMin());
            p.setBudgetMax(bo.getBudgetMax());
            p.setHealthGoal(bo.getHealthGoal());
            preferenceMapper.insert(p);
        } else {
            p.setTastePreference(bo.getTastePreference());
            p.setCuisinePreference(bo.getCuisinePreference());
            p.setBudgetMin(bo.getBudgetMin());
            p.setBudgetMax(bo.getBudgetMax());
            p.setHealthGoal(bo.getHealthGoal());
            preferenceMapper.updateById(p);
        }
        return toVo(p);
    }

    @Override
    public List<AvoidVo> listAvoid() {
        Long userId = requireUserId();
        return avoidMapper.selectList(new LambdaQueryWrapper<ShUserAvoid>()
                .eq(ShUserAvoid::getUserId, userId)
                .orderByAsc(ShUserAvoid::getId))
            .stream().map(this::toVo).collect(Collectors.toList());
    }

    @Override
    public AvoidVo addAvoid(UserAvoidBo bo) {
        Long userId = requireUserId();
        if (StrUtil.isBlank(bo.getItemName())) {
            throw new ServiceException("忌口项不能为空");
        }
        ShUserAvoid existing = avoidMapper.selectOne(new LambdaQueryWrapper<ShUserAvoid>()
            .eq(ShUserAvoid::getUserId, userId)
            .eq(ShUserAvoid::getItemName, bo.getItemName())
            .last("limit 1"));
        if (existing != null) {
            return toVo(existing);
        }
        ShUserAvoid avoid = new ShUserAvoid();
        avoid.setUserId(userId);
        avoid.setAvoidType(StrUtil.blankToDefault(bo.getAvoidType(), "AVOID"));
        avoid.setItemName(bo.getItemName());
        avoidMapper.insert(avoid);
        return toVo(avoid);
    }

    @Override
    public void removeAvoid(Long id) {
        Long userId = requireUserId();
        ShUserAvoid avoid = avoidMapper.selectById(id);
        if (avoid == null || !userId.equals(avoid.getUserId())) {
            throw new ServiceException("忌口项不存在");
        }
        avoidMapper.deleteById(id);
    }

    private Long requireUserId() {
        Long userId = AppLoginHelper.getUserId();
        if (userId == null) {
            throw new ServiceException("请先登录");
        }
        return userId;
    }

    private PreferenceVo toVo(ShUserPreference p) {
        if (p == null) {
            return null;
        }
        PreferenceVo vo = new PreferenceVo();
        vo.setTastePreference(p.getTastePreference());
        vo.setCuisinePreference(p.getCuisinePreference());
        vo.setBudgetMin(p.getBudgetMin());
        vo.setBudgetMax(p.getBudgetMax());
        vo.setHealthGoal(p.getHealthGoal());
        return vo;
    }

    private AvoidVo toVo(ShUserAvoid a) {
        AvoidVo vo = new AvoidVo();
        vo.setId(a.getId());
        vo.setAvoidType(a.getAvoidType());
        vo.setItemName(a.getItemName());
        return vo;
    }
}