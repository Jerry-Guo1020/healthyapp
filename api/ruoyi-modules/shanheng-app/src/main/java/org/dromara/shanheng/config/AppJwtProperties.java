package org.dromara.shanheng.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * App JWT 配置
 *
 * @author shanheng
 */
@Data
@Component
@ConfigurationProperties(prefix = "shanheng.jwt")
public class AppJwtProperties {

    /** JWT 签名密钥（生产环境务必替换） */
    private String secret = "shanheng-default-secret-please-change-in-prod";

    /** 有效期（分钟），默认 7 天 */
    private Long expireMinutes = 10080L;

}