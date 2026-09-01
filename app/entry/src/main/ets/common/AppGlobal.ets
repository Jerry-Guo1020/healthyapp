/**
 * 全局上下文持有（EntryAbility 启动时注入）
 */
export class AppGlobal {
  static context: Context | null = null;

  static setContext(ctx: Context): void {
    AppGlobal.context = ctx;
  }
}