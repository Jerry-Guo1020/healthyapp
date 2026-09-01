package org.dromara.shanheng.domain.bo;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.mybatis.core.domain.BaseEntity;

import java.math.BigDecimal;

/**
 * 菜品业务对象（管理端新增/编辑/查询）
 *
 * @author shanheng
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class ShDishBo extends BaseEntity {

    /** 菜品ID（新增时不传，雪花生成） */
    private Long id;

    /** 菜品名称 */
    @NotBlank(message = "菜品名称不能为空")
    private String name;

    /** 主分类ID */
    @NotNull(message = "主分类不能为空")
    private Long categoryId;

    /** 描述 */
    private String description;

    /** 封面图URL(R2) */
    private String coverUrl;

    /** 食材 JSON 数组字符串 */
    private String ingredients;

    /** 热量(kcal/份) */
    private Integer calorie;

    /** 辣度 0-3 */
    private Integer spicyLevel;

    /** 油度 0-3 */
    private Integer oilLevel;

    /** 是否清淡 0否 1是 */
    private Integer isLight;

    /** 是否暖胃 0否 1是 */
    private Integer isWarm;

    /** 是否易消化 0否 1是 */
    private Integer isEasyDigest;

    /** 价格下限 */
    private BigDecimal priceMin;

    /** 价格上限 */
    private BigDecimal priceMax;

    /** 蛋白质(g/100g) */
    private BigDecimal protein;

    /** 脂肪(g/100g) */
    private BigDecimal fat;

    /** 碳水化合物(g/100g) */
    private BigDecimal carbs;

    /** 状态 0草稿 1上架 2下架 3待审核 */
    private Integer status;

}