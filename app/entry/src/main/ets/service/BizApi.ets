import { ApiClient } from './ApiClient';
import { ApiResult, AppPageVo, BrowseHistoryVo, CategoryVo, DishVo } from '../model/ApiModels';

/**
 * 菜品查询参数
 */
export class DishQuery {
  pageNum: number = 1;
  pageSize: number = 10;
  categoryId: string = '';
  tagId: string = '';
  keyword: string = '';
  isLight: number = -1;
  sort: string = 'default';
}

/**
 * 业务数据接口（分类 / 菜品 / 收藏 / 历史）
 */
export class BizApi {
  /** 分类树 */
  static async listCategories(): Promise<ApiResult<CategoryVo[]>> {
    return ApiClient.get<CategoryVo[]>('/categories');
  }

  /** 菜品分页 */
  static async pageDishes(q: DishQuery): Promise<ApiResult<AppPageVo<DishVo>>> {
    let path = `/dishes?pageNum=${q.pageNum}&pageSize=${q.pageSize}`;
    if (q.categoryId !== '') {
      path += `&categoryId=${q.categoryId}`;
    }
    if (q.tagId !== '') {
      path += `&tagId=${q.tagId}`;
    }
    if (q.keyword !== '') {
      path += `&keyword=${encodeURIComponent(q.keyword)}`;
    }
    if (q.isLight >= 0) {
      path += `&isLight=${q.isLight}`;
    }
    if (q.sort !== 'default') {
      path += `&sort=${q.sort}`;
    }
    return ApiClient.get<AppPageVo<DishVo>>(path);
  }

  /** 菜品详情 */
  static async dishDetail(id: string): Promise<ApiResult<DishVo>> {
    return ApiClient.get<DishVo>(`/dishes/${id}`);
  }

  /** 添加收藏 */
  static async addFavorite(dishId: string): Promise<ApiResult<object>> {
    return ApiClient.post<object>(`/favorites/${dishId}`, null);
  }

  /** 取消收藏 */
  static async removeFavorite(dishId: string): Promise<ApiResult<object>> {
    return ApiClient.del<object>(`/favorites/${dishId}`);
  }

  /** 收藏列表 */
  static async favoritePage(pageNum: number, pageSize: number): Promise<ApiResult<AppPageVo<DishVo>>> {
    return ApiClient.get<AppPageVo<DishVo>>(`/favorites?pageNum=${pageNum}&pageSize=${pageSize}`);
  }

  /** 记录浏览 */
  static async recordHistory(dishId: string): Promise<ApiResult<object>> {
    return ApiClient.post<object>(`/history/${dishId}`, null);
  }

  /** 随机菜品（转盘抽签，count 1-12） */
  static async randomDishes(count: number, categoryId: string): Promise<ApiResult<DishVo[]>> {
    let path = `/dishes/random?count=${count}`;
    if (categoryId !== '') {
      path += `&categoryId=${categoryId}`;
    }
    return ApiClient.get<DishVo[]>(path);
  }

  /** 浏览历史列表 */
  static async historyPage(pageNum: number, pageSize: number): Promise<ApiResult<AppPageVo<BrowseHistoryVo>>> {
    return ApiClient.get<AppPageVo<BrowseHistoryVo>>(`/history?pageNum=${pageNum}&pageSize=${pageSize}`);
  }
}