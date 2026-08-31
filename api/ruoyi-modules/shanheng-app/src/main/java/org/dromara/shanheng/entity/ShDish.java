package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.mybatis.core.domain.BaseEntity;

import java.io.Serial;
import java.math.BigDecimal;

/**
 * 菜品对象 sh_dish
 *
 * @author shanheng
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sh_dish")
public class ShDish extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 菜品ID */
    @TableId(value = "id")
    private Long id;

    /** 菜品名称 */
    private String name;

    /** 主分类ID */
    private Long categoryId;

    /** 描述 */
    private String description;

    /** 封面图URL(R2) */
    private String coverUrl;

    /** 食材 JSON */
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

    /** 状态 0草稿 1上架 2下架 3待审核 */
    private Integer status;

    /** 浏览数 */
    private Integer viewCount;

    /** 收藏数 */
    private Integer favoriteCount;

    /** 被推荐次数 */
    private Integer recommendCount;

    /** 逻辑删除 0否 1是 */
    @TableLogic
    private Integer deleted;

}