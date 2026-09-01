import { ApiClient } from './ApiClient';
import { ApiResult, HealthAuthVo, HealthSummaryVo } from '../model/ApiModels';

/** 上报健康摘要请求体 */
export class UploadHealthSummaryBody {
  summaryDate: string = '';
  todaySteps: number = 0;
  sleepDurationMin: number = 0;
  sleepQualityScore: number = 0;
  restingHeartRate: number = 0;
  stressLevel: number = 0;
  activityLevel: number = 0;
  source: string = '';
  dataTime: string = '';
}

/** 授权状态请求体 */
export class HealthAuthStatusBody {
  authScope: string[] = [];
  status: number = 1;
}

/**
 * 健康数据接口（摘要 / 授权）
 */
export class HealthApi {
  /** 上报健康摘要 */
  static async uploadSummary(b: UploadHealthSummaryBody): Promise<ApiResult<object>> {
    return ApiClient.post<object>('/health/summary', b);
  }

  /** 最新健康摘要 */
  static async latestSummary(): Promise<ApiResult<HealthSummaryVo>> {
    return ApiClient.get<HealthSummaryVo>('/health/summary/latest');
  }

  /** 更新授权状态 */
  static async authStatus(b: HealthAuthStatusBody): Promise<ApiResult<HealthAuthVo>> {
    return ApiClient.post<HealthAuthVo>('/health/auth-status', b);
  }

  /** 取消健康授权 */
  static async revokeAuth(): Promise<ApiResult<object>> {
    return ApiClient.post<object>('/user/revoke-health-auth', null);
  }
}