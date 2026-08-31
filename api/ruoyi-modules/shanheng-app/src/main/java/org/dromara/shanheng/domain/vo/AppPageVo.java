package org.dromara.shanheng.domain.vo;

import com.baomidou.mybatisplus.core.metadata.IPage;
import lombok.Data;

import java.util.List;

/**
 * App 通用分页视图
 *
 * @author shanheng
 */
@Data
public class AppPageVo<T> {

    /** 总条数 */
    private Long total;

    /** 当前页 */
    private Long page;

    /** 每页大小 */
    private Long size;

    /** 数据列表 */
    private List<T> records;

    public static <T> AppPageVo<T> of(IPage<?> page, List<T> records) {
        AppPageVo<T> vo = new AppPageVo<>();
        vo.setTotal(page.getTotal());
        vo.setPage(page.getCurrent());
        vo.setSize(page.getSize());
        vo.setRecords(records);
        return vo;
    }

}