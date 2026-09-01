package org.dromara.shanheng.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.shanheng.domain.bo.ShDishBo;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.entity.ShDish;
import org.dromara.shanheng.mapper.ShDishMapper;
import org.dromara.shanheng.service.IShDishService;
import org.dromara.shanheng.support.DishAssembler;
import org.dromara.shanheng.support.USDAFoodClient;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 菜品管理服务实现（管理端）
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@Service
public class ShDishServiceImpl implements IShDishService {

    private final ShDishMapper dishMapper;
    private final DishAssembler dishAssembler;
    private final USDAFoodClient usdaFoodClient;

    @Override
    public TableDataInfo<DishVo> pageList(ShDishBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<ShDish> wrapper = new LambdaQueryWrapper<ShDish>()
            .like(StrUtil.isNotBlank(bo.getName()), ShDish::getName, bo.getName())
            .eq(bo.getCategoryId() != null, ShDish::getCategoryId, bo.getCategoryId())
            .eq(bo.getStatus() != null, ShDish::getStatus, bo.getStatus())
            .orderByDesc(ShDish::getId);
        Page<ShDish> page = dishMapper.selectPage(pageQuery.build(), wrapper);
        List<DishVo> vos = dishAssembler.assemble(page.getRecords());
        return new TableDataInfo<>(vos, page.getTotal());
    }

    @Override
    public DishVo getById(Long id) {
        ShDish dish = dishMapper.selectById(id);
        if (dish == null) {
            throw new ServiceException("菜品不存在");
        }
        return dishAssembler.assemble(List.of(dish)).get(0);
    }

    @Override
    public int insert(ShDishBo bo) {
        ShDish dish = BeanUtil.copyProperties(bo, ShDish.class);
        if (dish.getStatus() == null) {
            dish.setStatus(1);
        }
        return dishMapper.insert(dish);
    }

    @Override
    public int update(ShDishBo bo) {
        ShDish dish = BeanUtil.copyProperties(bo, ShDish.class);
        return dishMapper.updateById(dish);
    }

    @Override
    public int deleteByIds(List<Long> ids) {
        return dishMapper.deleteByIds(ids);
    }

    @Override
    public DishVo enrich(Long id, String keyword) {
        ShDish dish = dishMapper.selectById(id);
        if (dish == null) {
            throw new ServiceException("菜品不存在");
        }
        String query = StrUtil.isNotBlank(keyword)
            ? keyword.trim()
            : usdaFoodClient.resolveKeyword(dish.getName(), dish.getIngredients());
        if (StrUtil.isBlank(query)) {
            throw new ServiceException("无法识别食材英文关键词，请在补全时手动指定英文食材名");
        }
        USDAFoodClient.Nutrition nutrition = usdaFoodClient.search(query);
        if (nutrition == null) {
            throw new ServiceException("USDA 未查询到『" + query + "』的营养数据");
        }
        ShDish update = new ShDish();
        update.setId(id);
        update.setProtein(nutrition.protein);
        update.setFat(nutrition.fat);
        update.setCarbs(nutrition.carbs);
        dishMapper.updateById(update);
        return getById(id);
    }

}