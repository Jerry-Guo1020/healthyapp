package org.dromara.shanheng.domain.bo;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 华为账号授权码登录请求体
 *
 * @author shanheng
 */
@Data
public class HuaweiLoginBo {

    /** 华为授权码（App 通过 Account Kit 授权码模式获取） */
    @NotBlank(message = "授权码不能为空")
    private String code;

    /** 状态位（原样回传，防 CSRF，可选） */
    private String state;

}