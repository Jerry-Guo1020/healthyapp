import { ApiClient } from './ApiClient';
import { ApiResult, AppPageVo, RecommendationRecordVo, RecommendResultVo } from '../model/ApiModels';

/** 生成推荐请求体 */
export class RecommendBody {
  scene: string = '';
  categoryIds: string[] = [];
  budgetMin: number = 0;
  budgetMax: number = 0;
  useHealthData: boolean = true;
}

/** 推荐反馈请求体 */
export class RecommendFeedbackBody {
  dishId: string = '';
  feedbackType: string = 'LIKE';
  reason: string = '';
}

/**
 * 智能推荐接口
 */
export class RecommendApi {
  /** 生成推荐 */
  static async recommend(b: RecommendBody): Promise<ApiResult<RecommendResultVo>> {
    return ApiClient.post<RecommendResultVo>('/recommendations', b);
  }

  /** 推荐历史 */
  static async history(pageNum: number, pageSize: number): Promise<ApiResult<AppPageVo<RecommendationRecordVo>>> {
    return ApiClient.get<AppPageVo<RecommendationRecordVo>>(`/recommendations?pageNum=${pageNum}&pageSize=${pageSize}`);
  }

  /** 推荐反馈 */
  static async feedback(recordId: string, b: RecommendFeedbackBody): Promise<ApiResult<object>> {
    return ApiClient.post<object>(`/recommendations/${recordId}/feedback`, b);
  }
}