package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.mybatis.core.domain.BaseEntity;

import java.io.Serial;

/**
 * 标签对象 sh_tag
 *
 * @author shanheng
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sh_tag")
public class ShTag extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 标签ID */
    @TableId(value = "id")
    private Long id;

    /** 标签名 如 高蛋白/清淡/辣味 */
    private String name;

    /** 类型 HEALTH健康/TASTE口味/SCENE场景 */
    private String type;

    /** 排序值 */
    private Integer sort;

    /** 状态 0禁用 1启用 */
    private Integer status;

}