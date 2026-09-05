/**
 * 全局图标常量集中管理。
 *
 * 当前阶段使用 emoji 作为占位图标；正式替换为本地 PNG/SVG 图标时，按以下步骤：
 * 1. 将图标文件放入 app/entry/src/main/resources/base/media/（如 tab_home.png）
 * 2. 深色模式需不同图标时，将深色图标放入 resources/dark/media/，取同名文件即可自动覆盖
 * 3. 把下方对应常量改为 $r('app.media.xxx')，并按需把 Text 组件改造为 Image 组件
 *
 * 深浅色 / 选中态方案：
 * - 浅色图标放 base/media、深色图标放 dark/media（同名覆盖），随系统深浅模式自动切换；
 * - 底部导航选中/未选中建议准备两套图标（如 tab_home.png 未选中灰 + tab_home_active.png 选中品牌色），
 *   或在 Image 上使用 fillColor 着色（仅对单色 SVG/PNG 有效，emoji 无法着色）。
 *
 * 华为资源约束（打包体积）：
 * - 支持的图片格式：PNG / JPG / GIF / SVG / WEBP / BMP；
 * - 单个资源文件建议 ≤ 1MB，图标类建议用 SVG 或小尺寸 PNG（如 48×48 / 96×96）控制包体积；
 * - 应用 HAP 总大小受应用市场上架限制（详见 doc/07 与资源配置文档），图标应避免高清大图堆砌。
 */
export class AppIcons {
  // —— 底部导航 ——
  static readonly TAB_HOME: string = '🏠';      // → $r('app.media.tab_home')
  static readonly TAB_FOOD: string = '📷';      // → $r('app.media.tab_food')
  static readonly TAB_HEALTH: string = '🫀';    // → $r('app.media.tab_health')
  static readonly TAB_PROFILE: string = '👤';   // → $r('app.media.tab_profile')

  // —— 搜索 ——
  static readonly SEARCH: string = '🔍';        // → $r('app.media.ic_search')

  // —— 我的页 ——
  static readonly AVATAR_LOGIN: string = '👤';  // 登录态默认头像 → $r('app.media.avatar_default')
  static readonly AVATAR_GUEST: string = '🔒';  // 未登录态默认人像 → $r('app.media.avatar_guest')
  static readonly MENU_FAVORITE: string = '❤️'; // → $r('app.media.ic_favorite')
  static readonly MENU_HISTORY: string = '🕒';  // → $r('app.media.ic_history')
  static readonly MENU_ACCOUNT: string = '👤';  // → $r('app.media.ic_account')
}