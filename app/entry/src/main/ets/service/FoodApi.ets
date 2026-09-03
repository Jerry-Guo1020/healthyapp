import { ApiClient } from './ApiClient';
import { ApiResult, FoodRecognizeVo } from '../model/ApiModels';

/** 识别请求体 */
export class FoodRecognizeBody {
  image: string = '';
}

/**
 * 食物拍照识别接口
 */
export class FoodApi {
  /** 图片识别食物（base64） */
  static async recognize(image: string): Promise<ApiResult<FoodRecognizeVo>> {
    const body = new FoodRecognizeBody();
    body.image = image;
    return ApiClient.post<FoodRecognizeVo>('/food/recognize', body);
  }
}