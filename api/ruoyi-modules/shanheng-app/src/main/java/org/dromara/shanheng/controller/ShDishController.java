package org.dromara.shanheng.controller;

import cn.dev33.satoken.annotation.SaCheckPermission;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.shanheng.domain.bo.ShDishBo;
import org.dromara.shanheng.domain.vo.DishVo;
import org.dromara.shanheng.service.IShDishService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.Map;

/**
 * 菜品管理接口（管理端，sa-token 鉴权）
 *
 * @author shanheng
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/shanheng/dish")
public class ShDishController extends BaseController {

    private final IShDishService dishService;

    /** 分页列表 */
    @SaCheckPermission("shanheng:dish:list")
    @GetMapping("/list")
    public TableDataInfo<DishVo> list(ShDishBo bo, PageQuery pageQuery) {
        return dishService.pageList(bo, pageQuery);
    }

    /** 详情 */
    @SaCheckPermission("shanheng:dish:query")
    @GetMapping("/{id}")
    public R<DishVo> getInfo(@PathVariable Long id) {
        return R.ok(dishService.getById(id));
    }

    /** 新增 */
    @SaCheckPermission("shanheng:dish:add")
    @PostMapping
    public R<Void> add(@Validated @RequestBody ShDishBo bo) {
        return toAjax(dishService.insert(bo));
    }

    /** 修改 */
    @SaCheckPermission("shanheng:dish:edit")
    @PutMapping
    public R<Void> edit(@Validated @RequestBody ShDishBo bo) {
        return toAjax(dishService.update(bo));
    }

    /** 删除 */
    @SaCheckPermission("shanheng:dish:remove")
    @DeleteMapping("/{ids}")
    public R<Void> remove(@PathVariable Long[] ids) {
        return toAjax(dishService.deleteByIds(Arrays.asList(ids)));
    }

    /** 联网补全营养（USDA） */
    @SaCheckPermission("shanheng:dish:edit")
    @PostMapping("/enrich/{id}")
    public R<DishVo> enrich(@PathVariable Long id, @RequestBody(required = false) Map<String, Object> body) {
        String keyword = null;
        if (body != null && body.get("keyword") != null) {
            keyword = body.get("keyword").toString();
        }
        return R.ok(dishService.enrich(id, keyword));
    }

}