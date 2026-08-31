package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.mybatis.core.domain.BaseEntity;

import java.io.Serial;

/**
 * 菜品分类对象 sh_category
 *
 * @author shanheng
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sh_category")
public class ShCategory extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 分类ID */
    @TableId(value = "id")
    private Long id;

    /** 父分类ID 0为顶级 */
    private Long parentId;

    /** 分类名称 */
    private String name;

    /** 类型 MEAL餐次/CUISINE菜系/STAPLE主食/HEALTH健康/TASTE口味 */
    private String type;

    /** 图标URL */
    private String iconUrl;

    /** 排序值(越小越靠前) */
    private Integer sort;

    /** 是否首页快捷入口 0否 1是 */
    private Integer isQuick;

    /** 状态 0禁用 1启用 */
    private Integer status;

    /** 逻辑删除 0否 1是 */
    @TableLogic
    private Integer deleted;

}