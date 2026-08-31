package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * 用户对象 sh_user
 *
 * @author shanheng
 */
@Data
@TableName("sh_user")
public class ShUser implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 用户ID */
    @TableId(value = "id")
    private Long id;

    /** 手机号（登录账号，唯一） */
    private String phone;

    /** 昵称 */
    private String nickname;

    /** 头像URL */
    private String avatarUrl;

    /** 性别 0未知 1男 2女 */
    private Integer gender;

    /** 是否游客 0否 1是 */
    private Integer isGuest;

    /** 状态 0禁用 1正常 */
    private Integer status;

    /** 最后登录时间 */
    private Date lastLoginTime;

    /** 逻辑删除 0否 1是 */
    @TableLogic
    private Integer deleted;

    /** 创建时间 */
    private Date createTime;

    /** 更新时间 */
    private Date updateTime;

}
