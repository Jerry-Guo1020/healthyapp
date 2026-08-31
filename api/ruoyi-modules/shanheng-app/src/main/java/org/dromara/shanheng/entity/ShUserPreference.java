package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * 用户偏好对象 sh_user_preference
 *
 * @author shanheng
 */
@Data
@TableName("sh_user_preference")
public class ShUserPreference implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id")
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 口味偏好 JSON */
    private String tastePreference;

    /** 菜系偏好 JSON */
    private String cuisinePreference;

    /** 预算下限 */
    private BigDecimal budgetMin;

    /** 预算上限 */
    private BigDecimal budgetMax;

    /** 健康目标 LOSE_FAT/MUSCLE_GAIN/STOMACH/SUGAR_CONTROL */
    private String healthGoal;

    /** 创建时间 */
    private Date createTime;

    /** 更新时间 */
    private Date updateTime;

}
