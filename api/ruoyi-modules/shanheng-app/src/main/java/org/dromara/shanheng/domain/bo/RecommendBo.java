package org.dromara.shanheng.domain.bo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

/**
 * 生成推荐请求
 *
 * @author shanheng
 */
@Data
public class RecommendBo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 场景 早餐/午餐/晚餐/下午茶/宵夜 */
    private String scene;

    /** 限定分类ID */
    private List<Long> categoryIds;

    /** 预算下限 */
    private BigDecimal budgetMin;

    /** 预算上限 */
    private BigDecimal budgetMax;

    /** 是否使用健康数据参与推荐 */
    private Boolean useHealthData;
}