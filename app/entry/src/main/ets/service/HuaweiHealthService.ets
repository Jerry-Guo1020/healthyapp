import { healthStore } from '@kit.HealthServiceKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../common/Logger';

const TAG: string = 'HuaweiHealthService';

/**
 * 华为运动健康同步结果（一般权限：步数/卡路里/距离）
 */
export class HuaweiHealthSyncResult {
  success: boolean = false;
  steps: number = 0;
  calorie: number = 0;
  distance: number = 0;
  message: string = '';
}

/**
 * 华为运动健康数据服务（Health Service Kit）封装。
 *
 * ⚠️ 接入前准备（必须在 AppGallery Connect 完成）：
 * 1. 开通「运动健康服务」(Health Service Kit)
 * 2. 本文件只读取「一般权限」数据：步数 / 卡路里 / 距离（个人开发者可申请）
 * 3. 心率 / 睡眠 / 压力 / 血氧等属「受限权限」，需企业资质审核，暂以手动录入兜底
 * 4. 真机需登录华为账号并佩戴/连接华为设备或使用运动健康数据源
 *
 * 说明：授权弹窗由系统拉起，首次会请求 Health Service Kit 读权限。
 */
export class HuaweiHealthService {

  /**
   * 授权并同步「今日活动数据」（步数 / 卡路里 / 距离）。
   * @param ctx 页面上下文（UIAbility 的 context，用于初始化与授权）
   */
  static async authorizeAndSyncToday(ctx: common.Context): Promise<HuaweiHealthSyncResult> {
    const result = new HuaweiHealthSyncResult();
    try {
      // 1. 初始化 healthStore
      await healthStore.init(ctx);

      // 2. 申请读权限（DAILY_ACTIVITIES 为一般权限，个人开发者可申请）
      const authRequest: healthStore.AuthorizationRequest = {
        readDataTypes: [healthStore.healthDataTypes.DAILY_ACTIVITIES],
        writeDataTypes: []
      };
      const abilityCtx = ctx as common.UIAbilityContext;
      await healthStore.requestAuthorizations(abilityCtx, authRequest);

      // 3. 聚合今日步数/卡路里/距离
      const today: string = HuaweiHealthService.todayEn();
      const aggRequest: healthStore.AggregateRequest = {
        dataType: healthStore.healthDataTypes.DAILY_ACTIVITIES,
        startLocalDate: today,
        endLocalDate: today,
        metrics: {
          step: ['sum'],
          calorie: ['sum'],
          distance: ['sum']
        },
        groupBy: { unitType: healthStore.GroupUnitType.DAY, duration: 1 }
      };
      const resp: healthStore.AggregateResult[] = await healthStore.aggregateData(aggRequest);
      if (resp.length > 0) {
        const fields: Record<string, healthStore.AggregateMetrics> = resp[0].fields;
        result.steps = sumOf(fields.step);
        result.calorie = sumOf(fields.calorie);
        result.distance = sumOf(fields.distance);
      }
      result.success = true;
      result.message = '同步成功';
      Logger.info(TAG, `synced steps=${result.steps}, calorie=${result.calorie}, distance=${result.distance}`);
    } catch (e) {
      const err = e as BusinessError;
      result.message = `同步失败(${err.code ?? ''})：${err.message ?? '未知错误'}`;
      Logger.error(TAG, `sync fail code=${err.code} msg=${err.message}`);
    }
    return result;
  }

  /** 生成 MM/DD/YYYY（Health Kit 日期格式，en-US） */
  private static todayEn(): string {
    const d = new Date();
    const mm: string = String(d.getMonth() + 1).padStart(2, '0');
    const dd: string = String(d.getDate()).padStart(2, '0');
    return `${mm}/${dd}/${d.getFullYear()}`;
  }
}

/** 聚合指标取 sum，缺省按 0 处理 */
function sumOf(m: healthStore.AggregateMetrics): number {
  if (m.sum === undefined) {
    return 0;
  }
  return Math.round(m.sum);
}