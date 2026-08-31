package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.mybatis.core.domain.BaseEntity;

import java.io.Serial;

/**
 * 推荐规则对象 sh_recommendation_rule
 *
 * @author shanheng
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sh_recommendation_rule")
public class ShRecommendationRule extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /** ID */
    @TableId(value = "id")
    private Long id;

    /** 规则名 */
    private String ruleName;

    /** 规则标识 */
    private String ruleKey;

    /** 触发条件 JSON */
    private String conditions;

    /** 动作 INCLUDE/EXCLUDE/ADD_SCORE/SUB_SCORE */
    private String action;

    /** 分值 */
    private Integer score;

    /** 目标标签ID */
    private Long tagId;

    /** 推荐理由模板 */
    private String reasonTemplate;

    /** 优先级 */
    private Integer priority;

    /** 状态 0停用 1启用 */
    private Integer status;

}