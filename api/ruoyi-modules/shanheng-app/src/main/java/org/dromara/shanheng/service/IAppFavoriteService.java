package org.dromara.shanheng.service;

import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.DishVo;

/**
 * App 收藏服务接口
 *
 * @author shanheng
 */
public interface IAppFavoriteService {

    /**
     * 添加收藏
     */
    void add(Long dishId);

    /**
     * 取消收藏
     */
    void remove(Long dishId);

    /**
     * 收藏列表
     */
    AppPageVo<DishVo> page(Integer pageNum, Integer pageSize);

}