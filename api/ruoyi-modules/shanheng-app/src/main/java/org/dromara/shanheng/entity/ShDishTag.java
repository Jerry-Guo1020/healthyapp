package org.dromara.shanheng.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 菜品标签关系对象 sh_dish_tag
 *
 * @author shanheng
 */
@Data
@TableName("sh_dish_tag")
public class ShDishTag implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "id")
    private Long id;

    /** 菜品ID */
    private Long dishId;

    /** 标签ID */
    private Long tagId;

}