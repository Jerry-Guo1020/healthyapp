package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

/**
 * 健康授权状态视图
 *
 * @author shanheng
 */
@Data
public class HealthAuthVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 授权范围 */
    private List<String> authScope;

    /** 状态 0已撤销 1已授权 */
    private Integer status;

    /** 授权时间 */
    private String authorizeTime;
}