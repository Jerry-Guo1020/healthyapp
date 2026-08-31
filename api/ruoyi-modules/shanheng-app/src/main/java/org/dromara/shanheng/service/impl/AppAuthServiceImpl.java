package org.dromara.shanheng.service.impl;

import cn.hutool.core.util.RandomUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.redis.utils.RedisUtils;
import org.dromara.shanheng.domain.vo.AppLoginVo;
import org.dromara.shanheng.domain.vo.AppUserInfoVo;
import org.dromara.shanheng.entity.ShUser;
import org.dromara.shanheng.mapper.ShUserMapper;
import org.dromara.shanheng.service.IAppAuthService;
import org.dromara.shanheng.util.AppJwtUtil;
import org.springframework.stereotype.Service;

import java.time.Duration;

/**
 * App 认证服务实现
 *
 * @author shanheng
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class AppAuthServiceImpl implements IAppAuthService {

    private static final String SMS_CODE_KEY = "shanheng:sms:code:";
    private static final long SMS_CODE_TTL_MINUTES = 5;

    private final ShUserMapper userMapper;
    private final AppJwtUtil appJwtUtil;

    @Override
    public void sendCode(String phone) {
        String key = SMS_CODE_KEY + phone;
        if (RedisUtils.hasKey(key)) {
            throw new ServiceException("验证码已发送，请稍后再试");
        }
        String code = RandomUtil.randomNumbers(6);
        RedisUtils.setCacheObject(key, code, Duration.ofMinutes(SMS_CODE_TTL_MINUTES));
        // TODO: 接入短信服务商（阿里云/腾讯云），当前开发期仅打印日志
        log.info("发送验证码 phone={}, code={}", phone, code);
    }

    @Override
    public AppLoginVo loginByCode(String phone, String code) {
        String key = SMS_CODE_KEY + phone;
        String cached = RedisUtils.getCacheObject(key);
        if (cached == null || !cached.equals(code)) {
            throw new ServiceException("验证码错误或已过期");
        }
        // 校验通过后销毁验证码，防止重放
        RedisUtils.deleteObject(key);
        ShUser user = getOrCreateByPhone(phone);
        return buildLoginVo(user);
    }

    @Override
    public AppLoginVo guestLogin(String deviceId) {
        ShUser user = new ShUser();
        user.setNickname("游客" + RandomUtil.randomNumbers(4));
        user.setIsGuest(1);
        user.setStatus(1);
        userMapper.insert(user);
        return buildLoginVo(user);
    }

    /**
     * 按手机号查用户，不存在则注册
     */
    private ShUser getOrCreateByPhone(String phone) {
        ShUser user = userMapper.selectOne(new LambdaQueryWrapper<ShUser>().eq(ShUser::getPhone, phone));
        if (user == null) {
            user = new ShUser();
            user.setPhone(phone);
            user.setNickname("用户" + phone.substring(phone.length() - 4));
            user.setIsGuest(0);
            user.setStatus(1);
            userMapper.insert(user);
        }
        return user;
    }

    private AppLoginVo buildLoginVo(ShUser user) {
        AppUserInfoVo info = new AppUserInfoVo();
        info.setId(user.getId());
        info.setNickname(user.getNickname());
        info.setAvatarUrl(user.getAvatarUrl());
        info.setIsGuest(user.getIsGuest());

        AppLoginVo vo = new AppLoginVo();
        vo.setToken(appJwtUtil.createToken(user.getId(), Integer.valueOf(1).equals(user.getIsGuest())));
        vo.setUserInfo(info);
        return vo;
    }

}