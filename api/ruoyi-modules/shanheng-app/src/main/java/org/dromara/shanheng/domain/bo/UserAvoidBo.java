package org.dromara.shanheng.domain.bo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 用户忌口请求
 *
 * @author shanheng
 */
@Data
public class UserAvoidBo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 类型 ALLERGEN过敏原/AVOID忌口 */
    private String avoidType;

    /** 忌口项 如 花生/辣椒/麸质 */
    private String itemName;
}