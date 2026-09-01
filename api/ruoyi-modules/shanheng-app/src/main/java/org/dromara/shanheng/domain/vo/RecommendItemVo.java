package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 推荐项视图：菜品 + 推荐理由 + 健康建议
 *
 * @author shanheng
 */
@Data
public class RecommendItemVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 菜品 */
    private DishVo dish;

    /** 推荐理由 */
    private String reason;

    /** 健康建议 */
    private String healthAdvice;

    /** 命中分数 */
    private Integer score;
}