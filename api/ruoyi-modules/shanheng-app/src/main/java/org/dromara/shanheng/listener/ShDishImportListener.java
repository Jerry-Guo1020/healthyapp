package org.dromara.shanheng.listener;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONUtil;
import cn.idev.excel.context.AnalysisContext;
import cn.idev.excel.event.AnalysisEventListener;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.SpringUtils;
import org.dromara.common.excel.core.ExcelListener;
import org.dromara.common.excel.core.ExcelResult;
import org.dromara.shanheng.domain.bo.ShDishBo;
import org.dromara.shanheng.domain.vo.ShDishImportVo;
import org.dromara.shanheng.entity.ShCategory;
import org.dromara.shanheng.mapper.ShCategoryMapper;
import org.dromara.shanheng.service.IShDishService;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 菜品导入监听器（逐行校验 + 落库）
 *
 * @author shanheng
 */
@Slf4j
public class ShDishImportListener extends AnalysisEventListener<ShDishImportVo> implements ExcelListener<ShDishImportVo> {

    private final IShDishService dishService;
    private final Map<String, Long> categoryMap;

    private int successNum = 0;
    private int failureNum = 0;
    private final StringBuilder successMsg = new StringBuilder();
    private final StringBuilder failureMsg = new StringBuilder();

    public ShDishImportListener() {
        this.dishService = SpringUtils.getBean(IShDishService.class);
        ShCategoryMapper categoryMapper = SpringUtils.getBean(ShCategoryMapper.class);
        List<ShCategory> categories = categoryMapper.selectList(
            new LambdaQueryWrapper<ShCategory>().eq(ShCategory::getStatus, 1));
        // 分类名称 -> 分类ID 映射（同名取首个）
        this.categoryMap = categories.stream()
            .collect(Collectors.toMap(ShCategory::getName, ShCategory::getId, (a, b) -> a));
    }

    @Override
    public void invoke(ShDishImportVo vo, AnalysisContext context) {
        String name = vo.getName();
        try {
            if (StrUtil.isBlank(name)) {
                throw new ServiceException("菜品名称不能为空");
            }
            String categoryName = StrUtil.trim(vo.getCategoryName());
            Long categoryId = categoryMap.get(categoryName);
            if (categoryId == null) {
                throw new ServiceException("分类名称『" + categoryName + "』不存在，请填写已有分类");
            }
            ShDishBo bo = BeanUtil.toBean(vo, ShDishBo.class);
            bo.setId(null);
            bo.setCategoryId(categoryId);
            bo.setIngredients(toIngredientJson(vo.getIngredients()));
            dishService.insert(bo);
            successNum++;
            successMsg.append("<br/>").append(successNum).append("、").append(name).append(" 导入成功");
        } catch (Exception e) {
            failureNum++;
            String safeName = StrUtil.isBlank(name) ? "(名称为空)" : name;
            String msg = "<br/>" + failureNum + "、" + safeName + " 导入失败：" + e.getMessage();
            failureMsg.append(msg);
            log.error(msg, e);
        }
    }

    private String toIngredientJson(String ingredients) {
        if (StrUtil.isBlank(ingredients)) {
            return null;
        }
        List<String> list = StrUtil.splitTrim(ingredients, ',', '，', '、');
        return JSONUtil.toJsonStr(list);
    }

    @Override
    public void doAfterAllAnalysed(AnalysisContext context) {
    }

    @Override
    public ExcelResult<ShDishImportVo> getExcelResult() {
        return new ExcelResult<>() {
            @Override
            public String getAnalysis() {
                if (failureNum > 0) {
                    failureMsg.insert(0, "导入失败！共 " + failureNum + " 条数据有误：");
                    throw new ServiceException(failureMsg.toString());
                } else {
                    successMsg.insert(0, "导入成功！共 " + successNum + " 条：");
                }
                return successMsg.toString();
            }

            @Override
            public List<ShDishImportVo> getList() {
                return null;
            }

            @Override
            public List<String> getErrorList() {
                return null;
            }
        };
    }
}