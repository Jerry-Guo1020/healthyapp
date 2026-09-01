package org.dromara.shanheng.service;

import org.dromara.shanheng.domain.bo.UserAvoidBo;
import org.dromara.shanheng.domain.bo.UserPreferenceBo;
import org.dromara.shanheng.domain.vo.AvoidVo;
import org.dromara.shanheng.domain.vo.PreferenceVo;

import java.util.List;

/**
 * App 用户中心服务（偏好/忌口）
 *
 * @author shanheng
 */
public interface IAppUserService {

    /** 查询偏好 */
    PreferenceVo getPreference();

    /** 保存偏好 */
    PreferenceVo savePreference(UserPreferenceBo bo);

    /** 忌口列表 */
    List<AvoidVo> listAvoid();

    /** 新增忌口 */
    AvoidVo addAvoid(UserAvoidBo bo);

    /** 删除忌口 */
    void removeAvoid(Long id);
}