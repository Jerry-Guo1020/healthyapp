package org.dromara.shanheng.domain.vo;

import cn.idev.excel.annotation.ExcelProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 菜品导入 VO（Excel 模板列定义）
 *
 * @author shanheng
 */
@Data
@NoArgsConstructor
public class ShDishImportVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 菜品名称 */
    @ExcelProperty(value = "菜品名称")
    private String name;

    /** 分类名称（需填写已存在的分类，如：午餐/晚餐/养胃暖食） */
    @ExcelProperty(value = "分类名称")
    private String categoryName;

    /** 描述 */
    @ExcelProperty(value = "描述")
    private String description;

    /** 食材（逗号/中文逗号分隔） */
    @ExcelProperty(value = "食材(逗号分隔)")
    private String ingredients;

    /** 热量 kcal/份 */
    @ExcelProperty(value = "热量(kcal/份)")
    private Integer calorie;

    /** 辣度 0-3 */
    @ExcelProperty(value = "辣度(0-3)")
    private Integer spicyLevel;

    /** 油度 0-3 */
    @ExcelProperty(value = "油度(0-3)")
    private Integer oilLevel;

    /** 是否清淡 0否 1是 */
    @ExcelProperty(value = "清淡(0/1)")
    private Integer isLight;

    /** 是否暖胃 0否 1是 */
    @ExcelProperty(value = "暖胃(0/1)")
    private Integer isWarm;

    /** 是否易消化 0否 1是 */
    @ExcelProperty(value = "易消化(0/1)")
    private Integer isEasyDigest;

    /** 价格下限 */
    @ExcelProperty(value = "价格下限")
    private BigDecimal priceMin;

    /** 价格上限 */
    @ExcelProperty(value = "价格上限")
    private BigDecimal priceMax;

    /** 蛋白质 g/100g */
    @ExcelProperty(value = "蛋白质(g/100g)")
    private BigDecimal protein;

    /** 脂肪 g/100g */
    @ExcelProperty(value = "脂肪(g/100g)")
    private BigDecimal fat;

    /** 碳水化合物 g/100g */
    @ExcelProperty(value = "碳水(g/100g)")
    private BigDecimal carbs;

    /** 状态 0草稿 1上架 2下架 3待审核 */
    @ExcelProperty(value = "状态(1上架)")
    private Integer status;

}