package org.dromara.shanheng.domain.bo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

/**
 * 更新健康授权状态请求
 *
 * @author shanheng
 */
@Data
public class HealthAuthStatusBo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 授权范围 STEPS/SLEEP/HEART_RATE/STRESS */
    private List<String> authScope;

    /** 状态 1已授权（撤销由专门接口处理） */
    private Integer status;
}