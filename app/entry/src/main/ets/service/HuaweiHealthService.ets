import { healthStore } from '@kit.HealthServiceKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../common/Logger';
import { HealthAuthState } from '../common/HealthAuthState';
import { HealthApi, UploadHealthSummaryBody, HealthAuthStatusBody } from './HealthApi';

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
 */
export class HuaweiHealthService {

  /**
   * 授权并同步「今日活动数据」（步数 / 卡路里 / 距离）。
   */
  static async authorizeAndSyncToday(ctx: common.Context): Promise<HuaweiHealthSyncResult> {
    const result = new HuaweiHealthSyncResult();
    try {
      await healthStore.init(ctx);

      const authRequest: healthStore.AuthorizationRequest = {
        readDataTypes: [healthStore.healthDataTypes.DAILY_ACTIVITIES],
        writeDataTypes: []
      };
      const abilityCtx = ctx as common.UIAbilityContext;
      await healthStore.requestAuthorizations(abilityCtx, authRequest);

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

  /**
   * 完整流程：授权 → 同步 → 更新全局授权状态 → 后端记录授权 → 合并摘要上报。
   * 「我的」与「健康」两个入口统一调用，保证联动一致。
   */
  static async syncAndArchive(ctx: common.Context): Promise<HuaweiHealthSyncResult> {
    const r: HuaweiHealthSyncResult = await HuaweiHealthService.authorizeAndSyncToday(ctx);
    if (!r.success) {
      return r;
    }

    // 1. 更新全局授权状态（本地持久化）
    HealthAuthState.setAuthorized(true);

    // 2. 后端记录授权状态（失败不阻断）
    try {
      const ab = new HealthAuthStatusBody();
      ab.status = 1;
      ab.authScope = ['STEPS', 'ACTIVITY'];
      await HealthApi.authStatus(ab);
    } catch (e) {
      Logger.warn(TAG, 'record auth status fail');
    }

    // 3. 合并现有手动数据 + 华为步数，上报健康摘要（用于健康分析）
    try {
      const sRes = await HealthApi.latestSummary();
      const body = new UploadHealthSummaryBody();
      if (sRes.code === 200 && sRes.data != null) {
        body.sleepDurationMin = sRes.data.sleepDurationMin;
        body.sleepQualityScore = sRes.data.sleepQualityScore;
        body.restingHeartRate = sRes.data.restingHeartRate;
        body.stressLevel = sRes.data.stressLevel;
      }
      body.summaryDate = HuaweiHealthService.todayCn();
      body.source = 'HEALTH_KIT';
      body.dataTime = HuaweiHealthService.nowCn();
      body.todaySteps = r.steps;
      body.activityLevel = HuaweiHealthService.stepLevel(r.steps);
      await HealthApi.uploadSummary(body);
    } catch (e) {
      Logger.warn(TAG, 'archive summary fail');
    }

    return r;
  }

  /** 步数 → 活动等级（<4000→1，<8000→2，≥8000→3） */
  static stepLevel(steps: number): number {
    if (steps < 4000) {
      return 1;
    }
    if (steps < 8000) {
      return 2;
    }
    return 3;
  }

  /** 生成 MM/DD/YYYY（Health Kit 日期格式，en-US） */
  private static todayEn(): string {
    const d = new Date();
    const mm: string = String(d.getMonth() + 1).padStart(2, '0');
    const dd: string = String(d.getDate()).padStart(2, '0');
    return `${mm}/${dd}/${d.getFullYear()}`;
  }

  /** YYYY-MM-DD */
  static todayCn(): string {
    const d = new Date();
    return `${d.getFullYear()}-${HuaweiHealthService.pad(d.getMonth() + 1)}-${HuaweiHealthService.pad(d.getDate())}`;
  }

  /** YYYY-MM-DD HH:mm:ss */
  static nowCn(): string {
    const d = new Date();
    return `${HuaweiHealthService.todayCn()} ${HuaweiHealthService.pad(d.getHours())}:${HuaweiHealthService.pad(d.getMinutes())}:${HuaweiHealthService.pad(d.getSeconds())}`;
  }

  private static pad(n: number): string {
    return n < 10 ? '0' + n : '' + n;
  }
}

/** 聚合指标取 sum，缺省按 0 处理 */
function sumOf(m: healthStore.AggregateMetrics): number {
  if (m.sum === undefined) {
    return 0;
  }
  return Math.round(m.sum);
}