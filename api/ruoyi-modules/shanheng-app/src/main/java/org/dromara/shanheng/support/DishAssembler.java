package org.dromara.shanheng.support;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.entity.ShCategory;
import org.dromara.shanheng.entity.ShDish;
import org.dromara.shanheng.entity.ShDishTag;
import org.dromara.shanheng.entity.ShFavorite;
import org.dromara.shanheng.entity.ShTag;
import org.dromara.shanheng.mapper.ShCategoryMapper;
import org.dromara.shanheng.mapper.ShDishTagMapper;
import org.dromara.shanheng.mapper.ShFavoriteMapper;
import org.dromara.shanheng.mapper.ShTagMapper;
import org.dromara.shanheng.util.AppLoginHelper;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 菜品视图组装器：补全分类名、标签、收藏态（批量查询防 N+1）
 *
 * @author shanheng
 */
@Component
@RequiredArgsConstructor
public class DishAssembler {

    private final ShCategoryMapper categoryMapper;
    private final ShTagMapper tagMapper;
    private final ShDishTagMapper dishTagMapper;
    private final ShFavoriteMapper favoriteMapper;

    public List<DishVo> assemble(List<ShDish> dishes) {
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

        Map<Long, List<String>> tagMap = loadTags(dishIds);
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

}