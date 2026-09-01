import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 日志工具
 */
export class Logger {
  private static DOMAIN: number = 0x0011;

  static debug(tag: string, msg: string): void {
    hilog.debug(Logger.DOMAIN, tag, '%{public}s', msg);
  }

  static info(tag: string, msg: string): void {
    hilog.info(Logger.DOMAIN, tag, '%{public}s', msg);
  }

  static warn(tag: string, msg: string): void {
    hilog.warn(Logger.DOMAIN, tag, '%{public}s', msg);
  }

  static error(tag: string, msg: string): void {
    hilog.error(Logger.DOMAIN, tag, '%{public}s', msg);
  }
}