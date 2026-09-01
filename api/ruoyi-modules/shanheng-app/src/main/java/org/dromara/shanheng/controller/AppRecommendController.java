package org.dromara.shanheng.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.shanheng.domain.bo.RecommendBo;
import org.dromara.shanheng.domain.bo.RecommendFeedbackBo;
import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.RecommendResultVo;
import org.dromara.shanheng.domain.vo.RecommendationRecordVo;
import org.dromara.shanheng.service.IAppRecommendService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * App 智能推荐接口
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/app/v1/recommendations")
public class AppRecommendController {

    private final IAppRecommendService recommendService;

    /** 生成推荐 */
    @PostMapping
    public R<RecommendResultVo> recommend(@RequestBody RecommendBo bo) {
        return R.ok(recommendService.recommend(bo));
    }

    /** 推荐历史 */
    @GetMapping
    public R<AppPageVo<RecommendationRecordVo>> history(@RequestParam(defaultValue = "1") Integer pageNum,
                                                        @RequestParam(defaultValue = "10") Integer pageSize) {
        pageSize = Math.min(pageSize, 50);
        return R.ok(recommendService.history(pageNum, pageSize));
    }

    /** 推荐反馈 */
    @PostMapping("/{recordId}/feedback")
    public R<Void> feedback(@PathVariable Long recordId, @RequestBody RecommendFeedbackBo bo) {
        recommendService.feedback(recordId, bo);
        return R.ok();
    }
}