package org.dromara.shanheng.domain.bo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 推荐反馈请求
 *
 * @author shanheng
 */
@Data
public class RecommendFeedbackBo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 菜品ID */
    private Long dishId;

    /** 反馈类型 LIKE/DISLIKE */
    private String feedbackType;

    /** 原因 太辣/太油/价格高 */
    private String reason;
}