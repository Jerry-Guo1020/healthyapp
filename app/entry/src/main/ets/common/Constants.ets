/**
 * 膳衡 App 全局常量
 */

// 后端服务地址（测试服务器）
// 真机：需在服务器安全组放行 18080 端口
// 模拟器：若访问宿主机请按 DevEco 说明改用对应内网/映射地址
export const BASE_URL: string = 'http://43.139.91.62:18080';

// App 接口前缀
export const APP_API_PREFIX: string = '/app/v1';

// 本地持久化 Key
export const STORAGE_KEY_TOKEN: string = 'shanheng_token';
export const STORAGE_KEY_USER: string = 'shanheng_user';
export const STORAGE_KEY_HEALTH_AUTH: string = 'shanheng_health_auth';

// 主题色
export const COLOR_PRIMARY: string = '#00A86B';
export const COLOR_PRIMARY_DARK: string = '#008C59';
export const COLOR_BG: string = '#F5F6F7';
export const COLOR_CARD: string = '#FFFFFF';
export const COLOR_TEXT_MAIN: string = '#1A1A1A';
export const COLOR_TEXT_SUB: string = '#999999';
export const COLOR_TEXT_LIGHT: string = '#BBBBBB';
export const COLOR_DANGER: string = '#E5484D';
export const COLOR_WARNING: string = '#F5A623';
export const COLOR_BORDER: string = '#ECECEC';