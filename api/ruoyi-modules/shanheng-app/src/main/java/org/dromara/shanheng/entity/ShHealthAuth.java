package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * 健康数据授权记录对象 sh_health_auth
 *
 * @author shanheng
 */
@Data
@TableName("sh_health_auth")
public class ShHealthAuth implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id")
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 授权范围 JSON */
    private String authScope;

    /** 状态 0已撤销 1已授权 */
    private Integer status;

    /** 授权时间 */
    private Date authorizeTime;

    /** 撤销时间 */
    private Date revokeTime;

    /** 创建时间 */
    private Date createTime;

    /** 更新时间 */
    private Date updateTime;

}
