package org.dromara.shanheng.support;

import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpRequest;
import cn.hutool.json.JSONArray;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.redis.utils.RedisUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

/**
 * 百度 AI 菜品识别客户端。
 * <p>
 * 用途：App「拍照识别食物」——图片 base64 → 百度菜品识别，返回中文菜名 + 每 100g 卡路里 + 置信度。
 * <p>
 * 前置：百度智能云创建应用并开通「菜品识别」，获取 API Key / Secret Key。
 * access_token 有效期约 30 天，缓存到 Redis 复用（TTL 25 天）。
 *
 * @author shanheng
 */
@Slf4j
@Component
public class BaiduFoodClient {

    private static final String TOKEN_KEY = "shanheng:baidu:access_token";

    @Value("${shanheng.baidu.api-key:}")
    private String apiKey;

    @Value("${shanheng.baidu.secret-key:}")
    private String secretKey;

    @Value("${shanheng.baidu.token-url:https://aip.baidubce.com/oauth/2.0/token}")
    private String tokenUrl;

    @Value("${shanheng.baidu.dish-url:https://aip.baidubce.com/rest/2.0/image-classify/v2/dish}")
    private String dishUrl;

    /** 识别结果 */
    @Data
    public static class Dish {
        private String name;
        private String calorie;
        private String probability;
        private boolean hasCalorie;
    }

    /**
     * 菜品识别，返回候选列表（按置信度降序）；失败抛异常。
     *
     * @param imageBase64 图片 base64（可含 data:image/...;base64, 前缀，内部会剥离）
     */
    public List<Dish> recognize(String imageBase64) {
        if (StrUtil.isBlank(apiKey) || StrUtil.isBlank(secretKey)) {
            throw new ServiceException("菜品识别未配置（百度 AI api-key/secret-key 为空）");
        }
        String token = getAccessToken();
        String image = stripBase64Prefix(imageBase64);
        String body = HttpRequest.post(dishUrl + "?access_token=" + token)
            .form("image", image)
            .form("top_num", 5)
            .timeout(20000)
            .execute()
            .body();
        log.info("baidu dish recognize resp={}", body);
        JSONObject json = JSONUtil.parseObj(body);
        if (json.containsKey("error_code")) {
            throw new ServiceException("菜品识别失败：" + json.getStr("error_msg", "未知错误"));
        }
        JSONArray arr = json.getJSONArray("result");
        List<Dish> result = new ArrayList<>();
        if (arr != null) {
            for (int i = 0; i < arr.size(); i++) {
                JSONObject o = arr.getJSONObject(i);
                Dish d = new Dish();
                d.setName(o.getStr("name"));
                d.setCalorie(o.getStr("calorie"));
                d.setProbability(o.getStr("probability"));
                d.setHasCalorie(o.getBool("has_calorie", false));
                result.add(d);
            }
        }
        return result;
    }

    private String getAccessToken() {
        String cached = RedisUtils.getCacheObject(TOKEN_KEY);
        if (StrUtil.isNotBlank(cached)) {
            return cached;
        }
        String body = HttpRequest.post(tokenUrl)
            .form("grant_type", "client_credentials")
            .form("client_id", apiKey)
            .form("client_secret", secretKey)
            .timeout(20000)
            .execute()
            .body();
        JSONObject json = JSONUtil.parseObj(body);
        String token = json.getStr("access_token");
        if (StrUtil.isBlank(token)) {
            throw new ServiceException("获取百度 AI access_token 失败：" + json.getStr("error_description", "未知错误"));
        }
        // 官方有效期约 30 天，缓存 25 天规避边界
        RedisUtils.setCacheObject(TOKEN_KEY, token, Duration.ofDays(25));
        return token;
    }

    private String stripBase64Prefix(String image) {
        if (StrUtil.isBlank(image)) {
            return image;
        }
        int idx = image.indexOf("base64,");
        if (idx >= 0) {
            return image.substring(idx + "base64,".length());
        }
        return image;
    }

}