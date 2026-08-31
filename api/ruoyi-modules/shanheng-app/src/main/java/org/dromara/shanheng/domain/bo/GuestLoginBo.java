package org.dromara.shanheng.domain.bo;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 游客登录请求体
 *
 * @author shanheng
 */
@Data
public class GuestLoginBo {

    /** 设备唯一标识 */
    @NotBlank(message = "设备标识不能为空")
    private String deviceId;

}