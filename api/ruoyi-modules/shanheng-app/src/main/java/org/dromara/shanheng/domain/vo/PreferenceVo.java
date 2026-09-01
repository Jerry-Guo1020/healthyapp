package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 用户偏好视图
 *
 * @author shanheng
 */
@Data
public class PreferenceVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 口味偏好 JSON 字符串 */
    private String tastePreference;

    /** 菜系偏好 JSON 字符串 */
    private String cuisinePreference;

    /** 预算下限 */
    private BigDecimal budgetMin;

    /** 预算上限 */
    private BigDecimal budgetMax;

    /** 健康目标 */
    private String healthGoal;
}