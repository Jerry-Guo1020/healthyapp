import { router } from '@kit.ArkUI';
import { HealthApi, UploadHealthSummaryBody } from '../../service/HealthApi';
import { RecommendApi, RecommendBody } from '../../service/RecommendApi';
import { DishVo, RecommendItemVo } from '../../model/ApiModels';

/** 详情页路由参数（ArkTS 禁止无类型对象字面量） */
class DishDetailParams {
  dishId: string = '';
  name: string = '';
}

/**
 * 健康 Tab：健康摘要 + 手动记录状态 + 智能推荐
 * 说明：对接华为手表后，摘要来源为 HEALTH_KIT 自动同步；
 *      当前阶段用手动录入（MANUAL）跑通同一条推荐规则引擎。
 */
@Component
export struct HealthTab {
  @Prop @Watch('onActiveChange') active: boolean = false;

  // 摘要展示
  @State hasSummary: boolean = false;
  @State todaySteps: number = 0;
  @State sleepHours: string = '';
  @State stressText: string = '';
  @State activityText: string = '';
  @State summarySource: string = '';

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
    this.loadSummary();
  }

  onActiveChange(): void {
    if (this.active) {
      this.loadSummary();
    }
  }

  loadSummary(): void {
    HealthApi.latestSummary().then((res) => {
      if (res.code === 200 && res.data != null) {
        const s = res.data;
        this.hasSummary = true;
        this.todaySteps = s.todaySteps;
        this.sleepHours = (s.sleepDurationMin / 60).toFixed(1);
        this.stressText = s.stressLevel === 1 ? '低' : (s.stressLevel === 3 ? '高' : '中');
        this.activityText = s.activityLevel === 1 ? '少' : (s.activityLevel === 3 ? '多' : '一般');
        this.summarySource = s.source === 'HEALTH_KIT' ? '华为运动健康' : '手动录入';
      } else {
        this.hasSummary = false;
      }
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
        this.loadSummary();
        this.doRecommend();
      }
      this.submitting = false;
    });
  }

  doRecommend(): void {
    this.recommendLoading = true;
    const b = new RecommendBody();
    b.scene = '';
    b.useHealthData = true;
    RecommendApi.recommend(b).then((res) => {
      this.recommendLoading = false;
      if (res.code === 200 && res.data != null) {
        this.recommendations = res.data.recommendations;
        this.todayReminder = res.data.todayReminder;
        this.showRecommend = true;
      }
    });
  }

  private openDetail(dish: DishVo): void {
    const p = new DishDetailParams();
    p.dishId = dish.id;
    p.name = dish.name;
    router.pushUrl({
      url: 'pages/DishDetailPage',
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

  @Builder
  summaryMetric(name: string, value: string, unit: string) {
    Column() {
      Text(`${value}${unit}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
      Text(name)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  summaryCard() {
    Column() {
      Row() {
        Text('今日健康状态')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        Blank()
        if (this.hasSummary) {
          Text(this.summarySource)
            .fontSize(11)
            .fontColor('#00A86B')
            .backgroundColor('#00A86B14')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(4)
        }
      }
      .width('100%')

      if (!this.hasSummary) {
        Column() {
          Text('🫀')
            .fontSize(40)
          Text('暂无健康数据')
            .fontSize(15)
            .fontColor('#1A1A1A')
            .margin({ top: 8 })
          Text('记录今日状态，获得更精准的饮食推荐')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ top: 18, bottom: 18 })
        .justifyContent(FlexAlign.Center)
      } else {
        Row() {
          this.summaryMetric('今日步数', `${this.todaySteps}`, ' 步')
          this.summaryMetric('昨晚睡眠', this.sleepHours, ' 小时')
        }
        .width('100%')
        .margin({ top: 16 })
        Row() {
          this.summaryMetric('当前压力', this.stressText, '')
          this.summaryMetric('今日活动', this.activityText, '')
        }
        .width('100%')
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
  manualCard() {
    Column() {
      Text('手动记录今日状态')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
      Text('无手表也能体验健康推荐；对接华为手表后可自动同步')
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
          this.summaryCard()
          this.manualCard()
          if (this.showRecommend) {
            this.recommendSection()
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