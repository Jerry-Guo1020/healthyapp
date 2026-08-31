package org.dromara.shanheng.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.BrowseHistoryVo;
import org.dromara.shanheng.service.IAppHistoryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * App 浏览历史接口
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/app/v1/history")
public class AppHistoryController {

    private final IAppHistoryService historyService;

    /**
     * 记录浏览
     */
    @PostMapping("/{dishId}")
    public R<Void> record(@PathVariable Long dishId) {
        historyService.record(dishId);
        return R.ok();
    }

    /**
     * 浏览历史列表
     */
    @GetMapping
    public R<AppPageVo<BrowseHistoryVo>> page(@RequestParam(defaultValue = "1") Integer pageNum,
                                              @RequestParam(defaultValue = "10") Integer pageSize) {
        pageSize = Math.min(pageSize, 50);
        return R.ok(historyService.page(pageNum, pageSize));
    }

}