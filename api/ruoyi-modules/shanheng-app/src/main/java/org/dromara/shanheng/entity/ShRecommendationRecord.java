package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * 推荐记录对象 sh_recommendation_record
 *
 * @author shanheng
 */
@Data
@TableName("sh_recommendation_record")
public class ShRecommendationRecord implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id")
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 场景 早餐/午餐/晚餐/下午茶/宵夜 */
    private String scene;

    /** 输入快照 JSON */
    private String inputSnapshot;

    /** 推荐菜品ID列表 */
    private String dishIds;

    /** 推荐理由 */
    private String reason;

    /** 推荐时间 */
    private Date createTime;

}
