package org.dromara.shanheng.service.impl;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.domain.vo.FoodRecognizeVo;
import org.dromara.shanheng.entity.ShDish;
import org.dromara.shanheng.mapper.ShDishMapper;
import org.dromara.shanheng.service.IAppFoodService;
import org.dromara.shanheng.support.BaiduFoodClient;
import org.dromara.shanheng.support.DishAssembler;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

/**
 * App 食物识别服务实现：百度识别 → 本地菜品匹配 → 推荐
 *
 * @author shanheng
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class AppFoodServiceImpl implements IAppFoodService {

    private final BaiduFoodClient baiduFoodClient;
    private final ShDishMapper dishMapper;
    private final DishAssembler dishAssembler;

    @Override
    public FoodRecognizeVo recognize(String image) {
        List<BaiduFoodClient.Dish> candidates = baiduFoodClient.recognize(image);
        if (candidates.isEmpty()) {
            throw new ServiceException("未识别到食物，请换一张更清晰的照片");
        }
        // 逐个候选尝试匹配本地菜品
        FoodRecognizeVo vo = null;
        for (BaiduFoodClient.Dish d : candidates) {
            List<ShDish> matched = matchByName(d.getName());
            if (!matched.isEmpty()) {
                vo = buildVo(d, dishAssembler.assemble(matched).get(0));
                break;
            }
        }
        if (vo == null) {
            vo = buildVo(candidates.get(0), null);
        }
        vo.setRecommends(recommend(vo.getMatchedDish()));
        return vo;
    }

    private List<ShDish> matchByName(String name) {
        if (StrUtil.isBlank(name)) {
            return Collections.emptyList();
        }
        return dishMapper.selectList(new LambdaQueryWrapper<ShDish>()
            .eq(ShDish::getStatus, 1)
            .like(ShDish::getName, name)
            .last("limit 1"));
    }

    private FoodRecognizeVo buildVo(BaiduFoodClient.Dish d, DishVo matched) {
        FoodRecognizeVo vo = new FoodRecognizeVo();
        vo.setName(d.getName());
        vo.setCalorie(d.getCalorie());
        vo.setProbability(d.getProbability());
        vo.setHasCalorie(d.isHasCalorie());
        vo.setMatchedDish(matched);
        return vo;
    }

    private List<DishVo> recommend(DishVo matched) {
        LambdaQueryWrapper<ShDish> wrapper = new LambdaQueryWrapper<ShDish>()
            .eq(ShDish::getStatus, 1)
            .last("limit 6");
        if (matched != null && matched.getCategoryId() != null) {
            // 匹配到：推荐同分类其他菜品（排除自身），不足则补齐热门
            List<ShDish> same = dishMapper.selectList(new LambdaQueryWrapper<ShDish>()
                .eq(ShDish::getStatus, 1)
                .eq(ShDish::getCategoryId, matched.getCategoryId())
                .ne(ShDish::getId, matched.getId())
                .last("limit 6"));
            if (same.size() >= 3) {
                return dishAssembler.assemble(same);
            }
            return dishAssembler.assemble(same);
        }
        // 未匹配：按推荐次数降序
        wrapper.orderByDesc(ShDish::getRecommendCount);
        return dishAssembler.assemble(dishMapper.selectList(wrapper));
    }

}