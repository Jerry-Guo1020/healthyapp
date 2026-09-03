package org.dromara.shanheng.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Collections;
import java.util.List;

/**
 * 食物拍照识别结果视图
 *
 * @author shanheng
 */
@Data
public class FoodRecognizeVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 识别出的菜名 */
    private String name;

    /** 每 100g 卡路里文案（百度返回，如 "395大卡/100g"） */
    private String calorie;

    /** 置信度 */
    private String probability;

    /** 是否携带卡路里信息 */
    private Boolean hasCalorie;

    /** 匹配到的本地菜品（可能为 null） */
    private DishVo matchedDish;

    /** 推荐菜品列表 */
    private List<DishVo> recommends = Collections.emptyList();

}