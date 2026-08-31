package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * 第三方账号绑定对象 sh_user_auth
 *
 * @author shanheng
 */
@Data
@TableName("sh_user_auth")
public class ShUserAuth implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id")
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 认证类型 HUAWEI/PHONE */
    private String authType;

    /** 华为OpenID */
    private String openId;

    /** 华为UnionID */
    private String unionId;

    /** 华为账号手机号 */
    private String phone;

    /** 绑定状态 0解绑 1绑定 */
    private Integer status;

    /** 绑定时间 */
    private Date bindTime;

    /** 解绑时间 */
    private Date unbindTime;

    /** 创建时间 */
    private Date createTime;

    /** 更新时间 */
    private Date updateTime;

}
