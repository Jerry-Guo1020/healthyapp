package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 推荐记录视图
 *
 * @author shanheng
 */
@Data
public class RecommendationRecordVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** ID */
    private Long id;

    /** 场景 */
    private String scene;

    /** 推荐菜品ID列表(逗号分隔) */
    private String dishIds;

    /** 推荐理由 */
    private String reason;

    /** 推荐时间 */
    private String createTime;
}