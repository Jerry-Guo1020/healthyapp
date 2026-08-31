package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.util.List;

/**
 * 分类树视图
 *
 * @author shanheng
 */
@Data
public class CategoryVo {

    /** 分类ID */
    private Long id;

    /** 父分类ID */
    private Long parentId;

    /** 分类名称 */
    private String name;

    /** 分类类型 */
    private String type;

    /** 图标URL */
    private String iconUrl;

    /** 排序 */
    private Integer sort;

    /** 是否快捷入口 0否 1是 */
    private Integer isQuick;

    /** 子分类 */
    private List<CategoryVo> children;

}