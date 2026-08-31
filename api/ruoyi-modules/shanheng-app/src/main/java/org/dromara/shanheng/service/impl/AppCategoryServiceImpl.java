package org.dromara.shanheng.service.impl;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.dromara.shanheng.domain.vo.CategoryVo;
import org.dromara.shanheng.entity.ShCategory;
import org.dromara.shanheng.mapper.ShCategoryMapper;
import org.dromara.shanheng.service.IAppCategoryService;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * App 分类服务实现
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@Service
public class AppCategoryServiceImpl implements IAppCategoryService {

    private final ShCategoryMapper categoryMapper;

    @Override
    public List<CategoryVo> listTree(String type) {
        List<ShCategory> list = categoryMapper.selectList(new LambdaQueryWrapper<ShCategory>()
            .eq(StrUtil.isNotBlank(type), ShCategory::getType, type)
            .eq(ShCategory::getStatus, 1)
            .orderByAsc(ShCategory::getSort));

        Map<Long, List<CategoryVo>> groupByParent = list.stream()
            .map(this::toVo)
            .collect(Collectors.groupingBy(c -> c.getParentId() == null ? 0L : c.getParentId()));
        return buildTree(0L, groupByParent);
    }

    private CategoryVo toVo(ShCategory entity) {
        CategoryVo vo = new CategoryVo();
        vo.setId(entity.getId());
        vo.setParentId(entity.getParentId());
        vo.setName(entity.getName());
        vo.setType(entity.getType());
        vo.setIconUrl(entity.getIconUrl());
        vo.setSort(entity.getSort());
        vo.setIsQuick(entity.getIsQuick());
        return vo;
    }

    private List<CategoryVo> buildTree(Long parentId, Map<Long, List<CategoryVo>> group) {
        List<CategoryVo> children = group.get(parentId);
        if (children == null) {
            return Collections.emptyList();
        }
        for (CategoryVo child : children) {
            child.setChildren(buildTree(child.getId(), group));
        }
        return children;
    }

}