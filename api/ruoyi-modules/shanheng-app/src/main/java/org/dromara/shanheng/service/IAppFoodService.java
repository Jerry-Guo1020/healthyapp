package org.dromara.shanheng.service;

import org.dromara.shanheng.domain.vo.FoodRecognizeVo;

/**
 * App 食物识别服务接口
 *
 * @author shanheng
 */
public interface IAppFoodService {

    /**
     * 图片识别食物并给出推荐
     */
    FoodRecognizeVo recognize(String image);

}