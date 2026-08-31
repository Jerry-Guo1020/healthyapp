package org.dromara.shanheng.constant;

/**
 * 膳衡 App 业务常量
 *
 * @author shanheng
 */
public interface ShanhengConstants {

    /** App 端接口统一前缀 */
    String APP_API_PREFIX = "/app/v1";

    /** 健康数据来源：华为 Health Kit */
    String HEALTH_SOURCE_HEALTH_KIT = "HEALTH_KIT";

    /** 健康数据来源：手动输入（降级） */
    String HEALTH_SOURCE_MANUAL = "MANUAL";

    /** 推荐场景：餐次 */
    String[] MEAL_SCENES = {"BREAKFAST", "LUNCH", "DINNER", "AFTERNOON_TEA", "NIGHT_SNACK"};

}