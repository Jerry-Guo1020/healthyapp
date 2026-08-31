package org.dromara.shanheng.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.BrowseHistoryVo;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.entity.ShBrowseHistory;
import org.dromara.shanheng.entity.ShDish;
import org.dromara.shanheng.mapper.ShBrowseHistoryMapper;
import org.dromara.shanheng.mapper.ShDishMapper;
import org.dromara.shanheng.service.IAppHistoryService;
import org.dromara.shanheng.support.DishAssembler;
import org.dromara.shanheng.util.AppLoginHelper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * App 浏览历史服务实现
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@Service
public class AppHistoryServiceImpl implements IAppHistoryService {

    private final ShBrowseHistoryMapper browseHistoryMapper;
    private final ShDishMapper dishMapper;
    private final DishAssembler dishAssembler;

    @Override
    public void record(Long dishId) {
        Long userId = AppLoginHelper.getUserId();
        ShDish dish = dishMapper.selectById(dishId);
        if (dish == null) {
            throw new ServiceException("菜品不存在");
        }
        ShBrowseHistory history = new ShBrowseHistory();
        history.setUserId(userId);
        history.setDishId(dishId);
        browseHistoryMapper.insert(history);
        dishMapper.update(null, new LambdaUpdateWrapper<ShDish>()
            .eq(ShDish::getId, dishId)
            .setSql("view_count = view_count + 1"));
    }

    @Override
    public AppPageVo<BrowseHistoryVo> page(Integer pageNum, Integer pageSize) {
        Long userId = AppLoginHelper.getUserId();
        Page<ShBrowseHistory> page = browseHistoryMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<ShBrowseHistory>()
                .eq(ShBrowseHistory::getUserId, userId)
                .orderByDesc(ShBrowseHistory::getId));

        List<Long> dishIds = page.getRecords().stream().map(ShBrowseHistory::getDishId).collect(Collectors.toList());
        List<ShDish> dishes = dishIds.isEmpty()
            ? Collections.emptyList()
            : dishMapper.selectList(new LambdaQueryWrapper<ShDish>().in(ShDish::getId, dishIds));
        Map<Long, DishVo> dishMap = dishAssembler.assemble(dishes).stream()
            .collect(Collectors.toMap(DishVo::getId, v -> v, (a, b) -> a));

        List<BrowseHistoryVo> records = page.getRecords().stream()
            .map(h -> {
                BrowseHistoryVo vo = new BrowseHistoryVo();
                vo.setBrowseTime(h.getBrowseTime());
                vo.setDish(dishMap.get(h.getDishId()));
                return vo;
            })
            .filter(vo -> vo.getDish() != null)
            .collect(Collectors.toList());
        return AppPageVo.of(page, records);
    }

}