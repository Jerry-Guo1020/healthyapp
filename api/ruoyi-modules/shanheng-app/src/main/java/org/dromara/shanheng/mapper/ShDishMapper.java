package org.dromara.shanheng.mapper;

import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.entity.ShDish;

/**
 * 菜品 Mapper（App 端 + 管理端共用）
 *
 * @author shanheng
 */
public interface ShDishMapper extends BaseMapperPlus<ShDish, DishVo> {
}