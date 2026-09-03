package org.dromara.shanheng.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.shanheng.domain.bo.FoodRecognizeBo;
import org.dromara.shanheng.domain.vo.FoodRecognizeVo;
import org.dromara.shanheng.service.IAppFoodService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * App 食物识别接口
 *
 * @author shanheng
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/app/v1/food")
public class AppFoodController {

    private final IAppFoodService foodService;

    /**
     * 拍照识别食物并推荐
     */
    @PostMapping("/recognize")
    public R<FoodRecognizeVo> recognize(@Validated @RequestBody FoodRecognizeBo bo) {
        return R.ok(foodService.recognize(bo.getImage()));
    }

}