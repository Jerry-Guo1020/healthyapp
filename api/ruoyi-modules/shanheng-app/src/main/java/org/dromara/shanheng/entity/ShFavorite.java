package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * 收藏对象 sh_favorite
 *
 * @author shanheng
 */
@Data
@TableName("sh_favorite")
public class ShFavorite implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** ID */
    @TableId(value = "id")
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 菜品ID */
    private Long dishId;

    /** 收藏时间 */
    private Date createTime;

}