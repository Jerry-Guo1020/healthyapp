package org.dromara.shanheng.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.entity.ShCategory;
import org.dromara.shanheng.entity.ShDish;
import org.dromara.shanheng.entity.ShDishTag;
import org.dromara.shanheng.entity.ShFavorite;
import org.dromara.shanheng.entity.ShTag;
import org.dromara.shanheng.mapper.ShCategoryMapper;
import org.dromara.shanheng.mapper.ShDishMapper;
import org.dromara.shanheng.mapper.ShDishTagMapper;
import org.dromara.shanheng.mapper.ShFavoriteMapper;
import org.dromara.shanheng.mapper.ShTagMapper;
import org.dromara.shanheng.service.IAppDishService;
import org.dromara.shanheng.util.AppLoginHelper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
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
    private final ShCategoryMapper categoryMapper;
    private final ShTagMapper tagMapper;
    private final ShDishTagMapper dishTagMapper;
    private final ShFavoriteMapper favoriteMapper;

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
        return AppPageVo.of(page, assemble(page.getRecords()));
    }

    @Override
    public DishVo detail(Long id) {
        ShDish dish = dishMapper.selectOne(new LambdaQueryWrapper<ShDish>()
            .eq(ShDish::getId, id)
            .eq(ShDish::getStatus, 1));
        if (dish == null) {
            throw new ServiceException("菜品不存在或已下架");
        }
        return assemble(Collections.singletonList(dish)).get(0);
    }

    /**
     * 组装 VO：补分类名、标签、收藏态
     */
    private List<DishVo> assemble(List<ShDish> dishes) {
        if (dishes.isEmpty()) {
            return Collections.emptyList();
        }
        List<Long> dishIds = dishes.stream().map(ShDish::getId).collect(Collectors.toList());

        // 分类名称
        Set<Long> categoryIds = dishes.stream().map(ShDish::getCategoryId).collect(Collectors.toSet());
        Map<Long, String> categoryNames = new HashMap<>();
        if (!categoryIds.isEmpty()) {
            categoryMapper.selectList(new LambdaQueryWrapper<ShCategory>().in(ShCategory::getId, categoryIds))
                .forEach(c -> categoryNames.put(c.getId(), c.getName()));
        }

        // 标签
        Map<Long, List<String>> tagMap = loadTags(dishIds);

        // 收藏态
        Set<Long> favoriteSet = loadFavorites(dishIds);

        List<DishVo> result = new ArrayList<>(dishes.size());
        for (ShDish d : dishes) {
            DishVo vo = BeanUtil.copyProperties(d, DishVo.class);
            vo.setCategoryName(categoryNames.get(d.getCategoryId()));
            vo.setTags(tagMap.getOrDefault(d.getId(), Collections.emptyList()));
            vo.setFavorite(favoriteSet.contains(d.getId()));
            result.add(vo);
        }
        return result;
    }

    private Map<Long, List<String>> loadTags(List<Long> dishIds) {
        List<ShDishTag> relations = dishTagMapper.selectList(new LambdaQueryWrapper<ShDishTag>()
            .in(ShDishTag::getDishId, dishIds));
        if (relations.isEmpty()) {
            return Collections.emptyMap();
        }
        Set<Long> tagIds = relations.stream().map(ShDishTag::getTagId).collect(Collectors.toSet());
        Map<Long, String> idToName = tagMapper.selectList(new LambdaQueryWrapper<ShTag>()
                .in(ShTag::getId, tagIds)
                .eq(ShTag::getStatus, 1))
            .stream().collect(Collectors.toMap(ShTag::getId, ShTag::getName, (a, b) -> a));

        Map<Long, List<String>> dishToTags = new HashMap<>();
        for (ShDishTag relation : relations) {
            String tagName = idToName.get(relation.getTagId());
            if (tagName != null) {
                dishToTags.computeIfAbsent(relation.getDishId(), k -> new ArrayList<>()).add(tagName);
            }
        }
        return dishToTags;
    }

    private Set<Long> loadFavorites(List<Long> dishIds) {
        Long userId = AppLoginHelper.getUserId();
        if (userId == null) {
            return Collections.emptySet();
        }
        return favoriteMapper.selectList(new LambdaQueryWrapper<ShFavorite>()
                .eq(ShFavorite::getUserId, userId)
                .in(ShFavorite::getDishId, dishIds))
            .stream().map(ShFavorite::getDishId).collect(Collectors.toSet());
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