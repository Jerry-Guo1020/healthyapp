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
  protein: number = 0;
  fat: number = 0;
  carbs: number = 0;
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

// 健康摘要
export class HealthSummaryVo {
  id: string = '';
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

// 健康授权状态
export class HealthAuthVo {
  authScope: string[] = [];
  status: number = 0;
  authorizeTime: string = '';
}

// 用户偏好
export class PreferenceVo {
  tastePreference: string = '';
  cuisinePreference: string = '';
  budgetMin: number = 0;
  budgetMax: number = 0;
  healthGoal: string = '';
}

// 忌口
export class AvoidVo {
  id: string = '';
  avoidType: string = '';
  itemName: string = '';
}

// 推荐项
export class RecommendItemVo {
  dish: DishVo = new DishVo();
  reason: string = '';
  healthAdvice: string = '';
  score: number = 0;
}

// 推荐结果
export class RecommendResultVo {
  recordId: string = '';
  recommendations: RecommendItemVo[] = [];
  todayReminder: string = '';
  healthSummary: HealthSummaryVo | null = null;
}

// 推荐记录
export class RecommendationRecordVo {
  id: string = '';
  scene: string = '';
  dishIds: string = '';
  reason: string = '';
  createTime: string = '';
}

// 健康指标项
export class HealthMetricVo {
  key: string = '';
  icon: string = '';
  label: string = '';
  value: string = '';
  unit: string = '';
  level: number = 0;
  levelText: string = '';
  advice: string = '';
  progress: number = 0;
  score: number = 0;
}

// 健康分析报告
export class HealthAnalysisVo {
  hasData: boolean = false;
  totalScore: number = 0;
  totalLevel: string = '';
  summary: string = '';
  dietAdvice: string = '';
  metrics: HealthMetricVo[] = [];
  recommendations: RecommendItemVo[] = [];
  todayReminder: string = '';
}

// 食物拍照识别结果
export class FoodRecognizeVo {
  name: string = '';
  calorie: string = '';
  probability: string = '';
  hasCalorie: boolean = false;
  matchedDish: DishVo | null = null;
  recommends: DishVo[] = [];
}