package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * 用户忌口对象 sh_user_avoid
 *
 * @author shanheng
 */
@Data
@TableName("sh_user_avoid")
public class ShUserAvoid implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id")
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 类型 ALLERGEN过敏原/AVOID忌口 */
    private String avoidType;

    /** 忌口项 如花生/辣椒/麸质 */
    private String itemName;

    /** 创建时间 */
    private Date createTime;

}
