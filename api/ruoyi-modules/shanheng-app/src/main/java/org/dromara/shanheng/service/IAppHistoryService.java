package org.dromara.shanheng.service;

import org.dromara.shanheng.domain.vo.AppPageVo;
import org.dromara.shanheng.domain.vo.BrowseHistoryVo;

/**
 * App 浏览历史服务接口
 *
 * @author shanheng
 */
public interface IAppHistoryService {

    /**
     * 记录浏览（同时浏览数 +1）
     */
    void record(Long dishId);

    /**
     * 浏览历史分页
     */
    AppPageVo<BrowseHistoryVo> page(Integer pageNum, Integer pageSize);

}