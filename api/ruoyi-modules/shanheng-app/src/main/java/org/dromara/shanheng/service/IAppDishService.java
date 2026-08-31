package org.dromara.shanheng.service;

import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.DishVo;

/**
 * App 菜品服务接口
 *
 * @author shanheng
 */
public interface IAppDishService {

    /**
     * 菜品分页查询
     */
    AppPageVo<DishVo> pageQuery(Integer pageNum, Integer pageSize, Long categoryId, Long tagId,
                                String keyword, Integer isLight, String sort);

    /**
     * 菜品详情
     */
    DishVo detail(Long id);

}