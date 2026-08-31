package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * 浏览历史对象 sh_browse_history
 *
 * @author shanheng
 */
@Data
@TableName("sh_browse_history")
public class ShBrowseHistory implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id")
    private Long id;

    /** 用户ID(游客为空) */
    private Long userId;

    /** 游客设备标识 */
    private String deviceId;

    /** 菜品ID */
    private Long dishId;

    /** 浏览时间 */
    private Date browseTime;

}