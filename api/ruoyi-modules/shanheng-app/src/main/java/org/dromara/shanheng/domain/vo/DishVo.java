package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * 菜品视图
 *
 * @author shanheng
 */
@Data
public class DishVo {

    /** 菜品ID */
    private Long id;

    /** 菜品名称 */
    private String name;

    /** 主分类ID */
    private Long categoryId;

    /** 分类名称 */
    private String categoryName;

    /** 菜品描述 */
    private String description;

    /** 封面图URL */
    private String coverUrl;

    /** 食材清单 */
    private String ingredients;

    /** 热量(千卡) */
    private Integer calorie;

    /** 辣度 0-5 */
    private Integer spicyLevel;

    /** 油量等级 0-5 */
    private Integer oilLevel;

    /** 是否清淡 0否 1是 */
    private Integer isLight;

    /** 是否温热 0否 1是 */
    private Integer isWarm;

    /** 是否易消化 0否 1是 */
    private Integer isEasyDigest;

    /** 价格区间下限 */
    private BigDecimal priceMin;

    /** 价格区间上限 */
    private BigDecimal priceMax;

    /** 收藏数 */
    private Integer favoriteCount;

    /** 浏览数 */
    private Integer viewCount;

    /** 标签名列表 */
    private List<String> tags;

    /** 当前用户是否已收藏 */
    private Boolean favorite;

}