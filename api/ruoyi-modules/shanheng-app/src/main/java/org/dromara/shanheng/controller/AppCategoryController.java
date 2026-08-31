package org.dromara.shanheng.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.shanheng.domain.vo.CategoryVo;
import org.dromara.shanheng.service.IAppCategoryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * App 分类接口
 *
 * @author shanheng
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/app/v1/categories")
public class AppCategoryController {

    private final IAppCategoryService categoryService;

    /**
     * 分类树
     */
    @GetMapping
    public R<List<CategoryVo>> listTree(@RequestParam(required = false) String type) {
        return R.ok(categoryService.listTree(type));
    }

}