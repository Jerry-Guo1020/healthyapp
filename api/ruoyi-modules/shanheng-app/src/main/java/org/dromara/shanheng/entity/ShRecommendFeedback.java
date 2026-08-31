package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * 推荐反馈对象 sh_recommend_feedback
 *
 * @author shanheng
 */
@Data
@TableName("sh_recommend_feedback")
public class ShRecommendFeedback implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id")
    private Long id;

    /** 推荐记录ID */
    private Long recordId;

    /** 用户ID */
    private Long userId;

    /** 菜品ID */
    private Long dishId;

    /** 反馈类型 LIKE/DISLIKE */
    private String feedbackType;

    /** 原因 太辣/太油/价格高 */
    private String reason;

    /** 反馈时间 */
    private Date createTime;

}
