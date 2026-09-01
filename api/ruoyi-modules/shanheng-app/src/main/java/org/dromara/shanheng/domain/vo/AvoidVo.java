package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 忌口视图
 *
 * @author shanheng
 */
@Data
public class AvoidVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** ID */
    private Long id;

    /** 类型 ALLERGEN/AVOID */
    private String avoidType;

    /** 忌口项 */
    private String itemName;
}