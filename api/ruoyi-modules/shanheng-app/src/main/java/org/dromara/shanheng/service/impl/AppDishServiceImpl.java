package org.dromara.shanheng.service.impl;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.entity.ShDish;
import org.dromara.shanheng.entity.ShDishTag;
import org.dromara.shanheng.mapper.ShDishMapper;
import org.dromara.shanheng.mapper.ShDishTagMapper;
import org.dromara.shanheng.service.IAppDishService;
import org.dromara.shanheng.support.DishAssembler;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * App 菜品服务实现
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@Service
public class AppDishServiceImpl implements IAppDishService {

    private final ShDishMapper dishMapper;
    private final ShDishTagMapper dishTagMapper;
    private final DishAssembler dishAssembler;

    @Override
    public AppPageVo<DishVo> pageQuery(Integer pageNum, Integer pageSize, Long categoryId, Long tagId,
                                       String keyword, Integer isLight, String sort) {
        LambdaQueryWrapper<ShDish> wrapper = new LambdaQueryWrapper<ShDish>()
            .eq(ShDish::getStatus, 1)
            .eq(categoryId != null, ShDish::getCategoryId, categoryId)
            .eq(isLight != null, ShDish::getIsLight, isLight)
            .like(StrUtil.isNotBlank(keyword), ShDish::getName, keyword);

        // 按标签过滤：先查标签关联的菜品ID
        if (tagId != null) {
            List<Long> dishIds = dishTagMapper.selectList(new LambdaQueryWrapper<ShDishTag>()
                    .eq(ShDishTag::getTagId, tagId))
                .stream().map(ShDishTag::getDishId).distinct().collect(Collectors.toList());
            if (dishIds.isEmpty()) {
                return emptyPage(pageNum, pageSize);
            }
            wrapper.in(ShDish::getId, dishIds);
        }

        applySort(wrapper, sort);

        Page<ShDish> page = dishMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        return AppPageVo.of(page, dishAssembler.assemble(page.getRecords()));
    }

    @Override
    public DishVo detail(Long id) {
        ShDish dish = dishMapper.selectOne(new LambdaQueryWrapper<ShDish>()
            .eq(ShDish::getId, id)
            .eq(ShDish::getStatus, 1));
        if (dish == null) {
            throw new ServiceException("菜品不存在或已下架");
        }
        return dishAssembler.assemble(Collections.singletonList(dish)).get(0);
    }

    private void applySort(LambdaQueryWrapper<ShDish> wrapper, String sort) {
        if ("hot".equals(sort)) {
            wrapper.orderByDesc(ShDish::getViewCount);
        } else if ("favorite".equals(sort)) {
            wrapper.orderByDesc(ShDish::getFavoriteCount);
        } else {
            wrapper.orderByDesc(ShDish::getId);
        }
    }

    private AppPageVo<DishVo> emptyPage(Integer pageNum, Integer pageSize) {
        AppPageVo<DishVo> vo = new AppPageVo<>();
        vo.setTotal(0L);
        vo.setPage((long) pageNum);
        vo.setSize((long) pageSize);
        vo.setRecords(Collections.emptyList());
        return vo;
    }

}