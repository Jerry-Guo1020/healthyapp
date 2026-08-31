package org.dromara.shanheng.domain.bo;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 验证码登录请求体
 *
 * @author shanheng
 */
@Data
public class LoginByCodeBo {

    /** 手机号 */
    @NotBlank(message = "手机号不能为空")
    private String phone;

    /** 验证码 */
    @NotBlank(message = "验证码不能为空")
    private String code;

}