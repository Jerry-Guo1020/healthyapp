package org.dromara.shanheng.domain.bo;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 食物拍照识别请求体
 *
 * @author shanheng
 */
@Data
public class FoodRecognizeBo {

    /** 图片 base64（可含 data:image/...;base64, 前缀） */
    @NotBlank(message = "图片不能为空")
    private String image;

}