package org.dromara.shanheng.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.service.IAppFavoriteService;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * App 收藏接口
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/app/v1/favorites")
public class AppFavoriteController {

    private final IAppFavoriteService favoriteService;

    /**
     * 添加收藏
     */
    @PostMapping("/{dishId}")
    public R<Void> add(@PathVariable Long dishId) {
        favoriteService.add(dishId);
        return R.ok();
    }

    /**
     * 取消收藏
     */
    @DeleteMapping("/{dishId}")
    public R<Void> remove(@PathVariable Long dishId) {
        favoriteService.remove(dishId);
        return R.ok();
    }

    /**
     * 收藏列表
     */
    @GetMapping
    public R<AppPageVo<DishVo>> page(@RequestParam(defaultValue = "1") Integer pageNum,
                                     @RequestParam(defaultValue = "10") Integer pageSize) {
        pageSize = Math.min(pageSize, 50);
        return R.ok(favoriteService.page(pageNum, pageSize));
    }

}