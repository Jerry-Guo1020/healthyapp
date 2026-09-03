package org.dromara.shanheng.support;

import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpRequest;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * 华为账号服务（Account Kit）后端代理。
 * <p>
 * 授权码模式：App 通过 Account Kit 拿到 AuthorizationCode 后交给后端，
 * 后端用 code 换取 access_token，再读取华为用户信息（OpenID/UnionID/昵称/头像/手机号）。
 * <p>
 * 说明：AuthorizationCode 模式面向个人/企业开发者均开放；一键登录（ID Token）另有能力，
 * 此处仅实现授权码模式。相关地址与字段均可配置，便于按 AGC 实际环境微调。
 *
 * @author shanheng
 */
@Slf4j
@Component
public class HuaweiAccountClient {

    @Value("${shanheng.huawei.client-id:}")
    private String clientId;

    @Value("${shanheng.huawei.client-secret:}")
    private String clientSecret;

    @Value("${shanheng.huawei.token-url:https://oauth-login.cloud.huawei.com/oauth2/v3/token}")
    private String tokenUrl;

    @Value("${shanheng.huawei.userinfo-url:https://oauth-login.cloud.huawei.com/rest.php?nsp_svc=GOpen.oauth2.user.getTokenInfo}")
    private String userinfoUrl;

    /** 华为用户信息 */
    @Data
    public static class HuaweiUser {
        private String openId;
        private String unionId;
        private String nickname;
        private String avatarUrl;
        private String phone;
    }

    /**
     * 授权码换华为用户信息。
     */
    public HuaweiUser login(String code) {
        if (StrUtil.isBlank(clientId) || StrUtil.isBlank(clientSecret)) {
            throw new ServiceException("华为账号服务未配置（client_id/client_secret 为空）");
        }
        String accessToken = exchangeToken(code);
        return fetchUser(accessToken);
    }

    private String exchangeToken(String code) {
        String body = HttpRequest.post(tokenUrl)
            .form("grant_type", "authorization_code")
            .form("code", code)
            .form("client_id", clientId)
            .form("client_secret", clientSecret)
            .timeout(20000)
            .execute()
            .body();
        log.info("huawei exchange token resp={}", body);
        JSONObject json = JSONUtil.parseObj(body);
        String accessToken = json.getStr("access_token");
        if (StrUtil.isBlank(accessToken)) {
            throw new ServiceException("华为登录凭证换取失败：" + json.getStr("error_description", "未知错误"));
        }
        return accessToken;
    }

    private HuaweiUser fetchUser(String accessToken) {
        String body = HttpRequest.post(userinfoUrl)
            .form("access_token", accessToken)
            .timeout(20000)
            .execute()
            .body();
        log.info("huawei userinfo resp={}", body);
        JSONObject json = JSONUtil.parseObj(body);
        HuaweiUser user = new HuaweiUser();
        user.setOpenId(json.getStr("open_id"));
        user.setUnionId(json.getStr("union_id"));
        user.setNickname(json.getStr("display_name"));
        user.setAvatarUrl(json.getStr("head_picture_url"));
        user.setPhone(json.getStr("phone_number"));
        return user;
    }

}