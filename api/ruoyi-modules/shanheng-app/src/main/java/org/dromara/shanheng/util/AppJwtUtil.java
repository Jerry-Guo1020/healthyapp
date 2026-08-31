package org.dromara.shanheng.util;

import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import lombok.RequiredArgsConstructor;
import org.dromara.shanheng.config.AppJwtProperties;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

/**
 * App 端 JWT 工具（HS256，零第三方依赖）
 *
 * @author shanheng
 */
@Component
@RequiredArgsConstructor
public class AppJwtUtil {

    private static final String HEADER = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";

    private final AppJwtProperties properties;

    /**
     * 签发 Token
     */
    public String createToken(Long userId, boolean isGuest) {
        long now = System.currentTimeMillis() / 1000;
        long exp = now + properties.getExpireMinutes() * 60;
        String header = b64(HEADER);
        JSONObject payload = new JSONObject();
        payload.set("sub", userId);
        payload.set("guest", isGuest);
        payload.set("iat", now);
        payload.set("exp", exp);
        String payloadStr = b64(payload.toString());
        String signData = header + "." + payloadStr;
        return signData + "." + sign(signData);
    }

    /**
     * 解析并校验 Token，非法/过期抛 IllegalArgumentException
     */
    public AppLoginUser parse(String token) {
        try {
            String[] parts = token.split("\\.");
            if (parts.length != 3) {
                throw new IllegalArgumentException("token 格式错误");
            }
            String signData = parts[0] + "." + parts[1];
            if (!sign(signData).equals(parts[2])) {
                throw new IllegalArgumentException("token 签名校验失败");
            }
            String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);
            JSONObject payload = JSONUtil.parseObj(payloadJson);
            if (payload.getLong("exp") < System.currentTimeMillis() / 1000) {
                throw new IllegalArgumentException("token 已过期");
            }
            Long userId = payload.getLong("sub");
            boolean guest = payload.getBool("guest");
            return new AppLoginUser(userId, guest);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalArgumentException("token 解析失败", e);
        }
    }

    private String sign(String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(properties.getSecret().getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return Base64.getUrlEncoder().withoutPadding()
                .encodeToString(mac.doFinal(data.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException("JWT 签名失败", e);
        }
    }

    private String b64(String s) {
        return Base64.getUrlEncoder().withoutPadding()
            .encodeToString(s.getBytes(StandardCharsets.UTF_8));
    }

}