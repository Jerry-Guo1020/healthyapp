package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.util.Date;

/**
 * 浏览历史视图
 *
 * @author shanheng
 */
@Data
public class BrowseHistoryVo {

    /** 浏览时间 */
    private Date browseTime;

    /** 菜品信息 */
    private DishVo dish;

}