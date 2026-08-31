package org.dromara.shanheng.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * App 端 Web 配置：注册 JWT 拦截器
 *
 * @author shanheng
 */
@Configuration
@RequiredArgsConstructor
public class AppWebConfig implements WebMvcConfigurer {

    private final AppAuthInterceptor appAuthInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(appAuthInterceptor)
            .addPathPatterns("/app/v1/**")
            .excludePathPatterns(
                "/app/v1/auth/send-code",
                "/app/v1/auth/login-by-code",
                "/app/v1/auth/guest",
                "/app/v1/auth/huawei-login"
            );
    }

}