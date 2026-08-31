package org.dromara.shanheng.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.entity.ShDish;
import org.dromara.shanheng.entity.ShFavorite;
import org.dromara.shanheng.mapper.ShDishMapper;
import org.dromara.shanheng.mapper.ShFavoriteMapper;
import org.dromara.shanheng.service.IAppFavoriteService;
import org.dromara.shanheng.support.DishAssembler;
import org.dromara.shanheng.util.AppLoginHelper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * App 收藏服务实现
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@Service
public class AppFavoriteServiceImpl implements IAppFavoriteService {

    private final ShFavoriteMapper favoriteMapper;
    private final ShDishMapper dishMapper;
    private final DishAssembler dishAssembler;

    @Override
    public void add(Long dishId) {
        Long userId = AppLoginHelper.getUserId();
        ShDish dish = dishMapper.selectById(dishId);
        if (dish == null) {
            throw new ServiceException("菜品不存在");
        }
        Long count = favoriteMapper.selectCount(new LambdaQueryWrapper<ShFavorite>()
            .eq(ShFavorite::getUserId, userId)
            .eq(ShFavorite::getDishId, dishId));
        if (count > 0) {
            return; // 幂等
        }
        ShFavorite favorite = new ShFavorite();
        favorite.setUserId(userId);
        favorite.setDishId(dishId);
        favoriteMapper.insert(favorite);
        dishMapper.update(null, new LambdaUpdateWrapper<ShDish>()
            .eq(ShDish::getId, dishId)
            .setSql("favorite_count = favorite_count + 1"));
    }

    @Override
    public void remove(Long dishId) {
        Long userId = AppLoginHelper.getUserId();
        int deleted = favoriteMapper.delete(new LambdaQueryWrapper<ShFavorite>()
            .eq(ShFavorite::getUserId, userId)
            .eq(ShFavorite::getDishId, dishId));
        if (deleted > 0) {
            dishMapper.update(null, new LambdaUpdateWrapper<ShDish>()
                .eq(ShDish::getId, dishId)
                .setSql("favorite_count = GREATEST(favorite_count - 1, 0)"));
        }
    }

    @Override
    public AppPageVo<DishVo> page(Integer pageNum, Integer pageSize) {
        Long userId = AppLoginHelper.getUserId();
        Page<ShFavorite> page = favoriteMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<ShFavorite>()
                .eq(ShFavorite::getUserId, userId)
                .orderByDesc(ShFavorite::getId));

        List<Long> dishIds = page.getRecords().stream().map(ShFavorite::getDishId).collect(Collectors.toList());
        List<ShDish> dishes = dishIds.isEmpty()
            ? Collections.emptyList()
            : dishMapper.selectList(new LambdaQueryWrapper<ShDish>().in(ShDish::getId, dishIds));

        // 按收藏时间倒序还原顺序
        Map<Long, DishVo> dishMap = dishAssembler.assemble(dishes).stream()
            .collect(Collectors.toMap(DishVo::getId, v -> v, (a, b) -> a));
        List<DishVo> records = dishIds.stream()
            .map(dishMap::get)
            .filter(Objects::nonNull)
            .peek(v -> v.setFavorite(true))
            .collect(Collectors.toList());
        return AppPageVo.of(page, records);
    }

}