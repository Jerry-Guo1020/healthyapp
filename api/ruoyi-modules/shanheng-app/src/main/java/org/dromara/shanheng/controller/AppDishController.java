package org.dromara.shanheng.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.service.IAppDishService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * App 菜品接口
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/app/v1/dishes")
public class AppDishController {

    private final IAppDishService dishService;

    /**
     * 菜品分页（sort: default/hot/favorite）
     */
    @GetMapping
    public R<AppPageVo<DishVo>> page(@RequestParam(defaultValue = "1") Integer pageNum,
                                     @RequestParam(defaultValue = "10") Integer pageSize,
                                     @RequestParam(required = false) Long categoryId,
                                     @RequestParam(required = false) Long tagId,
                                     @RequestParam(required = false) String keyword,
                                     @RequestParam(required = false) Integer isLight,
                                     @RequestParam(required = false, defaultValue = "default") String sort) {
        // 单页上限 50，防止恶意拉全量
        pageSize = Math.min(pageSize, 50);
        return R.ok(dishService.pageQuery(pageNum, pageSize, categoryId, tagId, keyword, isLight, sort));
    }

    /**
     * 随机菜品（转盘抽签，count 1-12）
     */
    @GetMapping("/random")
    public R<List<DishVo>> random(@RequestParam(defaultValue = "6") Integer count,
                                  @RequestParam(required = false) Long categoryId) {
        return R.ok(dishService.randomList(count, categoryId));
    }

    /**
     * 菜品详情
     */
    @GetMapping("/{id}")
    public R<DishVo> detail(@PathVariable Long id) {
        return R.ok(dishService.detail(id));
    }

}