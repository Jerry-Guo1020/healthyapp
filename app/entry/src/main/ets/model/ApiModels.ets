/**
 * App 接口数据模型（与后端 shanheng-app 的 VO 一一对应）
 * 注意：后端 Long 主键已通过 Jackson 序列化为字符串，避免 JS 精度丢失
 */

// 统一响应包装 R<T>
export class ApiResult<T> {
  code: number = 0;
  msg: string = '';
  data: T | null = null;
}

// 用户信息
export class AppUserInfoVo {
  id: string = '';
  nickname: string = '';
  avatarUrl: string = '';
  isGuest: number = 0;
}

// 登录结果
export class AppLoginVo {
  token: string = '';
  userInfo: AppUserInfoVo = new AppUserInfoVo();
}

// 分类（树）
export class CategoryVo {
  id: string = '';
  parentId: string = '';
  name: string = '';
  type: string = '';
  iconUrl: string = '';
  sort: number = 0;
  isQuick: number = 0;
  children: CategoryVo[] = [];
}

// 菜品
export class DishVo {
  id: string = '';
  name: string = '';
  categoryId: string = '';
  categoryName: string = '';
  description: string = '';
  coverUrl: string = '';
  ingredients: string = '';
  calorie: number = 0;
  spicyLevel: number = 0;
  oilLevel: number = 0;
  isLight: number = 0;
  isWarm: number = 0;
  isEasyDigest: number = 0;
  priceMin: number = 0;
  priceMax: number = 0;
  favoriteCount: number = 0;
  viewCount: number = 0;
  tags: string[] = [];
  favorite: boolean = false;
}

// 通用分页
export class AppPageVo<T> {
  total: number = 0;
  page: number = 0;
  size: number = 0;
  records: T[] = [];
}

// 浏览历史
export class BrowseHistoryVo {
  browseTime: string = '';
  dish: DishVo = new DishVo();
}