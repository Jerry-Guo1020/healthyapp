package org.dromara.shanheng.service;

import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.shanheng.domain.bo.ShDishBo;
import org.dromara.shanheng.domain.vo.DishVo;

import java.util.List;

/**
 * 菜品管理服务（管理端）
 *
 * @author shanheng
 */
public interface IShDishService {

    /** 分页查询 */
    TableDataInfo<DishVo> pageList(ShDishBo bo, PageQuery pageQuery);

    /** 详情 */
    DishVo getById(Long id);

    /** 新增 */
    int insert(ShDishBo bo);

    /** 修改 */
    int update(ShDishBo bo);

    /** 批量删除（逻辑删除） */
    int deleteByIds(List<Long> ids);

    /**
     * 联网补全营养（USDA）：keyword 为空时由菜品名/食材自动推导英文关键词
     */
    DishVo enrich(Long id, String keyword);

}