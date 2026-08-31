package org.dromara.shanheng.service;

import org.dromara.shanheng.domain.vo.CategoryVo;

import java.util.List;

/**
 * App 分类服务接口
 *
 * @author shanheng
 */
public interface IAppCategoryService {

    /**
     * 查询分类树（type 为空查全部）
     */
    List<CategoryVo> listTree(String type);

}