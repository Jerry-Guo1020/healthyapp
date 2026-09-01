import { ApiClient } from './ApiClient';
import { ApiResult, AvoidVo, PreferenceVo } from '../model/ApiModels';

/** 偏好请求体 */
export class PreferenceBody {
  tastePreference: string = '';
  cuisinePreference: string = '';
  budgetMin: number = 0;
  budgetMax: number = 0;
  healthGoal: string = '';
}

/** 忌口请求体 */
export class AvoidBody {
  avoidType: string = 'AVOID';
  itemName: string = '';
}

/**
 * 用户中心接口（偏好 / 忌口）
 */
export class UserApi {
  /** 查询偏好 */
  static async getPreference(): Promise<ApiResult<PreferenceVo>> {
    return ApiClient.get<PreferenceVo>('/user/preference');
  }

  /** 保存偏好 */
  static async savePreference(b: PreferenceBody): Promise<ApiResult<PreferenceVo>> {
    return ApiClient.put<PreferenceVo>('/user/preference', b);
  }

  /** 忌口列表 */
  static async listAvoid(): Promise<ApiResult<AvoidVo[]>> {
    return ApiClient.get<AvoidVo[]>('/user/avoid');
  }

  /** 新增忌口 */
  static async addAvoid(b: AvoidBody): Promise<ApiResult<AvoidVo>> {
    return ApiClient.post<AvoidVo>('/user/avoid', b);
  }

  /** 删除忌口 */
  static async removeAvoid(id: string): Promise<ApiResult<object>> {
    return ApiClient.del<object>(`/user/avoid/${id}`);
  }
}