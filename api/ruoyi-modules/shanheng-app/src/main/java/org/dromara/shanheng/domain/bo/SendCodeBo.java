package org.dromara.shanheng.domain.bo;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 发送验证码请求体
 *
 * @author shanheng
 */
@Data
public class SendCodeBo {

    /** 手机号 */
    @NotBlank(message = "手机号不能为空")
    private String phone;

}