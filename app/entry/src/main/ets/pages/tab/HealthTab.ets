import { router } from '@kit.ArkUI';
import { UserSession } from '../../common/UserSession';
import { AuthGuard } from '../../common/AuthGuard';
import { HealthAuthState } from '../../common/HealthAuthState';
import { HealthApi, UploadHealthSummaryBody } from '../../service/HealthApi';
import { RecommendApi, RecommendBody } from '../../service/RecommendApi';
import { UserApi } from '../../service/UserApi';
import { HuaweiHealthService } from '../../service/HuaweiHealthService';
import { DishVo, RecommendItemVo, HealthAnalysisVo, HealthMetricVo } from '../../model/ApiModels';

/** 详情页路由参数（ArkTS 禁止无类型对象字面量） */
class DishDetailParams {
  dishId: string = '';
  name: string = '';
}

/**
 * 健康 Tab：卡片式健康分析 + 华为运动健康同步 + 手动记录 + 智能推荐
 * - 分析卡片：综合评分 / 逐项指标 / 饮食建议（后端 /health/analysis）
 * - 华为同步：Health Service Kit 一般权限（步数/卡路里/距离）
 * - 手动录入：无手表也能跑通同一条推荐规则引擎（MANUAL）
 */
@Component
export struct HealthTab {
  @Prop @Watch('onActiveChange') active: boolean = false;
  @State isGuest: boolean = true;

  // 健康分析
  @State analysisLoading: boolean = false;
  @State analysis: HealthAnalysisVo = new HealthAnalysisVo();

  // 华为同步
  @State syncing: boolean = false;
  @State syncMessage: string = '';
  @State syncedSteps: number = 0;
  @State syncedCalorie: number = 0;
  @State syncedDistance: number = 0;

  // 手动录入选项
  @State sleepOption: number = 2;    // 1不足 2正常 3充足
  @State stressOption: number = 1;   // 1低 2中 3高
  @State activityOption: number = 1; // 1少 2一般 3多

  // 推荐
  @State submitting: boolean = false;
  @State recommendLoading: boolean = false;
  @State showRecommend: boolean = false;
  @State recommendations: RecommendItemVo[] = [];
  @State todayReminder: string = '';

  aboutToAppear(): void {
    this.isGuest = UserSession.isGuest();
    this.loadAnalysis();
  }

  onActiveChange(): void {
    if (this.active) {
      this.isGuest = UserSession.isGuest();
      this.loadAnalysis();
    }
  }

  /** 加载健康分析报告 */
  loadAnalysis(): void {
    this.analysisLoading = true;
    HealthApi.analyze().then((res) => {
      this.analysisLoading = false;
      if (res.code === 200 && res.data != null) {
        this.analysis = res.data;
      } else {
        this.analysis = new HealthAnalysisVo();
      }
    });
  }

  /** 同步华为运动健康（授权→同步→归档→联动状态，与「我的」入口一致） */
  syncHuawei(): void {
    if (!AuthGuard.requireAccount()) {
      return;
    }
    const ctx = this.getUIContext().getHostContext();
    if (ctx === undefined) {
      this.syncMessage = '无法获取应用上下文';
      return;
    }
    this.syncing = true;
    this.syncMessage = '';
    HuaweiHealthService.syncAndArchive(ctx).then((r) => {
      this.syncing = false;
      this.syncMessage = r.message;
      if (!r.success) {
        return;
      }
      this.syncedSteps = r.steps;
      this.syncedCalorie = r.calorie;
      this.syncedDistance = r.distance;
      this.loadAnalysis();
      this.doRecommend();
    });
  }

  submitAndRecommend(): void {
    const body = new UploadHealthSummaryBody();
    body.summaryDate = this.todayStr();
    body.source = 'MANUAL';
    body.dataTime = this.nowStr();
    if (this.sleepOption === 1) {
      body.sleepDurationMin = 300;
      body.sleepQualityScore = 55;
    } else if (this.sleepOption === 2) {
      body.sleepDurationMin = 450;
      body.sleepQualityScore = 78;
    } else {
      body.sleepDurationMin = 540;
      body.sleepQualityScore = 88;
    }
    body.stressLevel = this.stressOption;
    body.activityLevel = this.activityOption;
    if (this.activityOption === 1) {
      body.todaySteps = 2500;
    } else if (this.activityOption === 2) {
      body.todaySteps = 6000;
    } else {
      body.todaySteps = 12000;
    }

    this.submitting = true;
    HealthApi.uploadSummary(body).then((res) => {
      if (res.code === 200) {
        this.loadAnalysis();
        this.doRecommend();
      }
      this.submitting = false;
    });
  }

  doRecommend(): void {
    this.recommendLoading = true;
    // 读取用户预算偏好，随推荐一起生效
    UserApi.getPreference().then((pRes) => {
      const b = new RecommendBody();
      b.scene = '';
      b.useHealthData = true;
      if (pRes.code === 200 && pRes.data != null) {
        b.budgetMin = pRes.data.budgetMin;
        b.budgetMax = pRes.data.budgetMax;
      }
      RecommendApi.recommend(b).then((res) => {
        this.recommendLoading = false;
        if (res.code === 200 && res.data != null) {
          this.recommendations = res.data.recommendations;
          this.todayReminder = res.data.todayReminder;
          this.showRecommend = true;
        }
      });
    });
  }

  private stepLevel(steps: number): number {
    if (steps < 4000) {
      return 1;
    }
    if (steps < 8000) {
      return 2;
    }
    return 3;
  }

  private openDetail(dish: DishVo): void {
    const p = new DishDetailParams();
    p.dishId = dish.id;
    p.name = dish.name;
    router.pushUrl({
      url: 'pages/dish/DishDetailPage',
      params: p
    });
  }

  private selected(kind: number, value: number): boolean {
    if (kind === 0) {
      return this.sleepOption === value;
    }
    if (kind === 1) {
      return this.stressOption === value;
    }
    return this.activityOption === value;
  }

  private pad(n: number): string {
    return n < 10 ? '0' + n : '' + n;
  }

  private todayStr(): string {
    const d = new Date();
    return `${d.getFullYear()}-${this.pad(d.getMonth() + 1)}-${this.pad(d.getDate())}`;
  }

  private nowStr(): string {
    const d = new Date();
    return `${this.todayStr()} ${this.pad(d.getHours())}:${this.pad(d.getMinutes())}:${this.pad(d.getSeconds())}`;
  }

  /** 指标等级颜色 1优秀绿 2良好蓝 3一般橙 4需关注红 */
  private levelColor(level: number): string {
    if (level === 1) {
      return '#00A86B';
    }
    if (level === 2) {
      return '#4A90E2';
    }
    if (level === 3) {
      return '#F5A623';
    }
    return '#FF5B5B';
  }

  private scoreColor(score: number): string {
    if (score >= 85) {
      return '#00A86B';
    }
    if (score >= 70) {
      return '#4A90E2';
    }
    if (score >= 55) {
      return '#F5A623';
    }
    return '#FF5B5B';
  }

  @Builder
  pickChip(label: string, value: number, kind: number) {
    Text(label)
      .fontSize(13)
      .fontColor(this.selected(kind, value) ? '#FFFFFF' : '#555555')
      .backgroundColor(this.selected(kind, value) ? '#00A86B' : '#F0F2F3')
      .padding({ left: 16, right: 16, top: 7, bottom: 7 })
      .borderRadius(16)
      .onClick(() => {
        if (kind === 0) {
          this.sleepOption = value;
        } else if (kind === 1) {
          this.stressOption = value;
        } else {
          this.activityOption = value;
        }
      })
  }

  @Builder
  optionGroup(title: string, kind: number) {
    Column() {
      Text(title)
        .fontSize(13)
        .fontColor('#1A1A1A')
        .width('100%')
      Row({ space: 10 }) {
        if (kind === 0) {
          this.pickChip('不足', 1, 0)
          this.pickChip('正常', 2, 0)
          this.pickChip('充足', 3, 0)
        } else if (kind === 1) {
          this.pickChip('低', 1, 1)
          this.pickChip('中', 2, 1)
          this.pickChip('高', 3, 1)
        } else {
          this.pickChip('少', 1, 2)
          this.pickChip('一般', 2, 2)
          this.pickChip('多', 3, 2)
        }
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .margin({ top: 14 })
  }

  // ---------- 游客引导 ----------

  @Builder
  guestGuideCard() {
    Column() {
      Text('🫀')
        .fontSize(50)
      Text('登录后开启健康分析')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .margin({ top: 12 })
      Text('结合步数、睡眠、心率等健康数据')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ top: 8 })
      Text('为你科学推荐每一餐')
        .fontSize(13)
        .fontColor('#999999')
      Button('去登录')
        .width('80%')
        .height(44)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#00A86B')
        .borderRadius(22)
        .margin({ top: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/login/LoginPage' });
        })
    }
    .width('92%')
    .padding({ top: 30, bottom: 30 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 8 })
  }

  // ---------- 分析卡片 ----------

  @Builder
  analysisCard() {
    Column() {
      Row() {
        Text('健康分析')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        Blank()
        Text('数据驱动 · 饮食联动')
          .fontSize(11)
          .fontColor('#999999')
      }
      .width('100%')

      if (this.analysisLoading) {
        Row() {
          LoadingProgress()
            .width(28)
            .height(28)
            .color('#00A86B')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 24, bottom: 24 })
      } else if (!this.analysis.hasData) {
        Column() {
          Text('🫀')
            .fontSize(44)
          Text('暂无健康数据')
            .fontSize(15)
            .fontColor('#1A1A1A')
            .margin({ top: 8 })
          Text('同步华为运动健康或手动记录，生成个性化分析')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ top: 18, bottom: 18 })
        .justifyContent(FlexAlign.Center)
      } else {
        Row() {
          Column() {
            Text(`${this.analysis.totalScore}`)
              .fontSize(46)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.scoreColor(this.analysis.totalScore))
            Text('综合评分')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text(this.analysis.totalLevel)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.scoreColor(this.analysis.totalScore))
              .backgroundColor('#F0F2F3')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(12)
            Text(this.analysis.summary)
              .fontSize(12)
              .fontColor('#666666')
              .margin({ top: 8 })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 18 })
        }
        .width('100%')
        .margin({ top: 16 })

        Row() {
          Text('🥗')
            .fontSize(14)
          Text(this.analysis.dietAdvice)
            .fontSize(12)
            .fontColor('#666666')
            .layoutWeight(1)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#F0F8F3')
        .borderRadius(8)
        .margin({ top: 14 })
      }
    }
    .width('92%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 6 })
  }

  @Builder
  metricCard(m: HealthMetricVo) {
    Column() {
      Row() {
        Text(m.icon)
          .fontSize(24)
        Column() {
          Text(m.label)
            .fontSize(11)
            .fontColor('#999999')
          Row() {
            Text(m.value)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
            if (m.unit !== '') {
              Text(m.unit)
                .fontSize(11)
                .fontColor('#999999')
                .margin({ left: 2 })
            }
          }
          .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 8 })
        .layoutWeight(1)

        Text(m.levelText)
          .fontSize(11)
          .fontColor(this.levelColor(m.level))
          .backgroundColor('#F0F2F3')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(10)
      }
      .width('100%')

      Progress({ value: m.progress, total: 100, type: ProgressType.Linear })
        .width('100%')
        .height(6)
        .color(this.levelColor(m.level))
        .margin({ top: 12 })

      Text(m.advice)
        .fontSize(11)
        .fontColor('#888888')
        .width('100%')
        .margin({ top: 8 })
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  metricGrid() {
    Grid() {
      ForEach(this.analysis.metrics, (m: HealthMetricVo) => {
        GridItem() {
          this.metricCard(m)
        }
      }, (m: HealthMetricVo) => m.key)
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(10)
    .rowsGap(10)
    .width('92%')
    .margin({ top: 12 })
  }

  // ---------- 华为同步卡片 ----------

  @Builder
  huaweiCard() {
    Column() {
      Row() {
        Text('华为运动健康同步')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        Blank()
        Text(HealthAuthState.isAuthorized() ? '已授权' : '未授权')
          .fontSize(12)
          .fontColor(HealthAuthState.isAuthorized() ? '#00A86B' : '#999999')
      }
      .width('100%')

      if (this.syncMessage !== '') {
        Text(this.syncMessage)
          .fontSize(12)
          .fontColor('#F5A623')
          .width('100%')
          .margin({ top: 8 })
      }

      if (this.syncedSteps > 0) {
        Row() {
          this.miniMetric('今日步数', `${this.syncedSteps} 步`)
          this.miniMetric('消耗', `${this.syncedCalorie} 千卡`)
          this.miniMetric('距离', `${(this.syncedDistance / 1000).toFixed(1)} km`)
        }
        .width('100%')
        .margin({ top: 12 })
      }

      Button(this.syncing ? '同步中...' : '同步华为运动健康')
        .width('100%')
        .height(42)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#00A86B')
        .borderRadius(21)
        .margin({ top: 14 })
        .onClick(() => {
          this.syncHuawei();
        })
    }
    .width('92%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 12 })
  }

  @Builder
  miniMetric(name: string, value: string) {
    Column() {
      Text(value)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
      Text(name)
        .fontSize(11)
        .fontColor('#999999')
        .margin({ top: 3 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  // ---------- 手动录入卡片 ----------

  @Builder
  manualCard() {
    Column() {
      Text('手动记录今日状态')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
      Text('无手表也能体验健康推荐；对接华为设备后可自动同步')
        .fontSize(11)
        .fontColor('#999999')
        .margin({ top: 4 })

      this.optionGroup('昨晚睡眠', 0)
      this.optionGroup('当前压力', 1)
      this.optionGroup('今日活动', 2)

      Button(this.submitting ? '提交中...' : '上报并生成推荐')
        .width('100%')
        .height(44)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#00A86B')
        .borderRadius(22)
        .margin({ top: 18 })
        .onClick(() => {
          this.submitAndRecommend();
        })
    }
    .width('92%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 12 })
  }

  // ---------- 推荐 ----------

  @Builder
  recommendCard(item: RecommendItemVo) {
    Row() {
      if (item.dish.coverUrl !== '') {
        Image(item.dish.coverUrl)
          .width(76)
          .height(76)
          .borderRadius(10)
          .objectFit(ImageFit.Cover)
      } else {
        Text('🍽️')
          .width(76)
          .height(76)
          .fontSize(34)
          .textAlign(TextAlign.Center)
          .backgroundColor('#EAF5EF')
          .borderRadius(10)
      }

      Column() {
        Text(item.dish.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        if (item.reason !== '') {
          Text(`💡 ${item.reason}`)
            .fontSize(12)
            .fontColor('#00A86B')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ top: 4 })
        }

        Row() {
          Text(`${item.dish.calorie} 千卡`)
            .fontSize(11)
            .fontColor('#F5A623')
          if (item.dish.tags.length > 0) {
            Text(item.dish.tags.slice(0, 2).join(' · '))
              .fontSize(11)
              .fontColor('#00A86B')
              .margin({ left: 8 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
        .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(11)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(() => {
      this.openDetail(item.dish);
    })
  }

  @Builder
  recommendSection() {
    Column() {
      Row() {
        Text('为你推荐')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        Blank()
        Text(`${this.recommendations.length} 道`)
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')

      if (this.todayReminder !== '') {
        Row() {
          Text(`⏰ ${this.todayReminder}`)
            .fontSize(12)
            .fontColor('#F5A623')
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#FFF7E6')
        .borderRadius(8)
        .margin({ top: 10 })
      }

      if (this.recommendLoading) {
        Row() {
          LoadingProgress()
            .width(28)
            .height(28)
            .color('#00A86B')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 16 })
      } else {
        ForEach(this.recommendations, (item: RecommendItemVo) => {
          Column() {
            this.recommendCard(item)
          }
          .width('100%')
          .margin({ top: 10 })
        }, (item: RecommendItemVo) => item.dish.id)
      }
    }
    .width('92%')
    .margin({ top: 14 })
  }

  build() {
    Column() {
      Row() {
        Text('健康')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 8 })

      Scroll() {
        Column() {
          if (this.isGuest) {
            this.guestGuideCard()
          } else {
            this.analysisCard()
            if (this.analysis.hasData) {
              this.metricGrid()
            }
            this.huaweiCard()
            this.manualCard()
            if (this.showRecommend) {
              this.recommendSection()
            }
          }
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}