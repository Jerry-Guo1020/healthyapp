package org.dromara.shanheng.service.impl;

import cn.hutool.core.util.RandomUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.redis.utils.RedisUtils;
import org.dromara.shanheng.domain.bo.HuaweiLoginBo;
import org.dromara.shanheng.domain.vo.AppLoginVo;
import org.dromara.shanheng.domain.vo.AppUserInfoVo;
import org.dromara.shanheng.entity.ShUser;
import org.dromara.shanheng.entity.ShUserAuth;
import org.dromara.shanheng.mapper.ShUserAuthMapper;
import org.dromara.shanheng.mapper.ShUserMapper;
import org.dromara.shanheng.service.IAppAuthService;
import org.dromara.shanheng.support.HuaweiAccountClient;
import org.dromara.shanheng.util.AppJwtUtil;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Date;

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
    private final ShUserAuthMapper userAuthMapper;
    private final HuaweiAccountClient huaweiAccountClient;
    private final AppJwtUtil appJwtUtil;

    @Override
    public void sendCode(String phone) {
        String key = SMS_CODE_KEY + phone;
        if (RedisUtils.hasKey(key)) {
            throw new ServiceException("验证码已发送，请稍后再试");
        }
        String code = RandomUtil.randomNumbers(6);
        RedisUtils.setCacheObject(key, code, Duration.ofMinutes(SMS_CODE_TTL_MINUTES));
        // 开发期短信通道未接入，仅记录日志（生产接入后改为真实下发）
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

    @Override
    public AppLoginVo huaweiLogin(HuaweiLoginBo bo) {
        if (bo == null || StrUtil.isBlank(bo.getCode())) {
            throw new ServiceException("缺少华为授权码");
        }
        HuaweiAccountClient.HuaweiUser hu = huaweiAccountClient.login(bo.getCode());
        if (hu == null || StrUtil.isBlank(hu.getUnionId())) {
            throw new ServiceException("获取华为用户信息失败，请确认已开通账号服务并勾选 openid 权限");
        }
        // 按 UnionID 查历史绑定
        ShUserAuth auth = userAuthMapper.selectOne(new LambdaQueryWrapper<ShUserAuth>()
            .eq(ShUserAuth::getAuthType, "HUAWEI")
            .eq(ShUserAuth::getUnionId, hu.getUnionId())
            .eq(ShUserAuth::getStatus, 1)
            .last("limit 1"));
        ShUser user;
        if (auth != null) {
            user = userMapper.selectById(auth.getUserId());
            if (user == null) {
                throw new ServiceException("绑定账号不存在");
            }
        } else {
            user = new ShUser();
            user.setNickname(StrUtil.blankToDefault(hu.getNickname(), "华为用户"));
            user.setAvatarUrl(hu.getAvatarUrl());
            user.setIsGuest(0);
            user.setStatus(1);
            // 华为返回手机号时：已存在同手机号用户则合并，否则写入
            if (StrUtil.isNotBlank(hu.getPhone())) {
                ShUser exist = userMapper.selectOne(new LambdaQueryWrapper<ShUser>().eq(ShUser::getPhone, hu.getPhone()));
                if (exist != null) {
                    user = exist;
                } else {
                    user.setPhone(hu.getPhone());
                }
            }
            if (user.getId() == null) {
                userMapper.insert(user);
            }
            ShUserAuth newAuth = new ShUserAuth();
            newAuth.setUserId(user.getId());
            newAuth.setAuthType("HUAWEI");
            newAuth.setOpenId(hu.getOpenId());
            newAuth.setUnionId(hu.getUnionId());
            newAuth.setPhone(hu.getPhone());
            newAuth.setStatus(1);
            newAuth.setBindTime(new Date());
            userAuthMapper.insert(newAuth);
        }
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