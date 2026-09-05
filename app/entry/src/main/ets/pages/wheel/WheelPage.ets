import { router, promptAction } from '@kit.ArkUI';
import { BizApi } from '../../service/BizApi';
import { DishVo } from '../../model/ApiModels';
import { COLOR_PRIMARY } from '../../common/Constants';

// 详情页路由参数（ArkTS 禁止无类型对象字面量）
class WheelDetailParams {
  dishId: string = '';
  name: string = '';
}

/**
 * 转盘抽签页：随机 N 道菜，转盘动画决定「今天吃什么」。
 */
@Entry
@Component
struct WheelPage {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private wheelSize: number = 280;
  private colors: string[] = ['#F9C74F', '#F9844A', '#43AA8B', '#577590', '#F94144', '#90BE6D',
    '#4D908E', '#F3722C', '#277DA1', '#8D99AE', '#9B5DE5', '#EA8185'];

  @State candidates: DishVo[] = [];
  @State loading: boolean = true;
  @State wheelRotate: number = 0;
  @State spinning: boolean = false;
  @State resultIndex: number = -1;

  aboutToAppear(): void {
    this.loadRandom();
  }

  loadRandom(): void {
    this.loading = true;
    this.resultIndex = -1;
    BizApi.randomDishes(6, '').then((res) => {
      this.loading = false;
      if (res.code === 200 && res.data != null && res.data.length > 0) {
        this.candidates = res.data;
        this.drawWheel();
      } else {
        this.candidates = [];
      }
    });
  }

  drawWheel(): void {
    const n = this.candidates.length;
    const c = this.wheelSize / 2;
    const r = this.wheelSize / 2 - 6;
    this.ctx.clearRect(0, 0, this.wheelSize, this.wheelSize);
    if (n === 0) {
      return;
    }
    const sector = (Math.PI * 2) / n;
    for (let i = 0; i < n; i++) {
      const start = -Math.PI / 2 + i * sector;
      const end = start + sector;
      // 扇形
      this.ctx.beginPath();
      this.ctx.moveTo(c, c);
      this.ctx.arc(c, c, r, start, end);
      this.ctx.closePath();
      this.ctx.fillStyle = this.colors[i % this.colors.length];
      this.ctx.fill();
      this.ctx.strokeStyle = '#FFFFFF';
      this.ctx.lineWidth = 2;
      this.ctx.stroke();

      // 菜品名（沿径向从中心向外，字号 22px，名超 3 字截断以保证扇形可读）
      const mid = start + sector / 2;
      let name = this.candidates[i].name;
      if (name.length > 3) {
        name = name.substring(0, 3);
      }
      this.ctx.save();
      this.ctx.translate(c, c);
      this.ctx.rotate(mid);
      this.ctx.fillStyle = '#FFFFFF';
      this.ctx.font = 'bold 22px sans-serif';
      this.ctx.textAlign = 'left';
      this.ctx.textBaseline = 'middle';
      this.ctx.fillText(name, r * 0.45, 0);
      this.ctx.restore();
    }
    // 中心圆点
    this.ctx.beginPath();
    this.ctx.arc(c, c, 26, 0, Math.PI * 2);
    this.ctx.fillStyle = '#FFFFFF';
    this.ctx.fill();
    this.ctx.beginPath();
    this.ctx.arc(c, c, 14, 0, Math.PI * 2);
    this.ctx.fillStyle = COLOR_PRIMARY;
    this.ctx.fill();
  }

  spin(): void {
    if (this.spinning || this.candidates.length === 0) {
      return;
    }
    this.spinning = true;
    this.resultIndex = -1;
    const n = this.candidates.length;
    const target = Math.floor(Math.random() * n);
    const sectorDeg = 360 / n;
    // 让 target 扇形中心停在顶部指针处：顺时针补角
    const remainder = (((-target * sectorDeg - this.wheelRotate) % 360) + 360) % 360;
    const rotTarget = this.wheelRotate + 360 * 5 + remainder;

    animateTo({
      duration: 4200,
      curve: Curve.EaseOut,
      onFinish: () => {
        this.spinning = false;
        this.resultIndex = target;
      }
    }, () => {
      this.wheelRotate = rotTarget;
    });
  }

  again(): void {
    this.drawWheel();
    this.spin();
  }

  /** 换一批：弹窗提示 + 转盘过渡动画 */
  refreshBatch(): void {
    if (this.loading) {
      return;
    }
    promptAction.showToast({ message: '正在换一批菜品…' });
    animateTo({ duration: 380, curve: Curve.EaseInOut }, () => {
      this.wheelRotate = this.wheelRotate + 180;
    });
    this.loadRandom();
  }

  goDetail(): void {
    if (this.resultIndex < 0 || this.resultIndex >= this.candidates.length) {
      return;
    }
    const d = this.candidates[this.resultIndex];
    const p = new WheelDetailParams();
    p.dishId = d.id;
    p.name = d.name;
    router.pushUrl({
      url: 'pages/dish/DishDetailPage',
      params: p
    });
  }

  @Builder
  wheel() {
    Stack({ alignContent: Alignment.Top }) {
      Canvas(this.ctx)
        .width(this.wheelSize)
        .height(this.wheelSize)
        .rotate({ angle: this.wheelRotate })
        .onReady(() => {
          this.drawWheel();
        })
      // 顶部指针
      Text('▼')
        .fontSize(26)
        .fontColor($r('app.color.danger'))
        .position({ x: this.wheelSize / 2 - 13, y: -14 })
    }
    .width(this.wheelSize)
    .height(this.wheelSize)
  }

  @Builder
  resultCard() {
    if (this.resultIndex >= 0 && this.resultIndex < this.candidates.length) {
      Column() {
        Text('🎉 就吃它！')
          .fontSize(14)
          .fontColor($r('app.color.text_sub'))
        Text(this.candidates[this.resultIndex].name)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_main'))
          .margin({ top: 8 })
        Text(`${this.candidates[this.resultIndex].calorie} 千卡 · ${this.candidates[this.resultIndex].categoryName}`)
          .fontSize(13)
          .fontColor($r('app.color.text_sub'))
          .margin({ top: 6 })
        Row({ space: 14 }) {
          Button('再抽一次')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor($r('app.color.brand'))
            .backgroundColor($r('app.color.brand_bg14'))
            .onClick(() => {
              this.refreshBatch();
            })
          Button('去查看')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor($r('app.color.text_on_brand'))
            .backgroundColor($r('app.color.brand'))
            .onClick(() => {
              this.goDetail();
            })
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .width('88%')
      .padding(20)
      .backgroundColor($r('app.color.bg_card'))
      .borderRadius(16)
      .margin({ top: 24 })
    }
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor($r('app.color.text_main'))
          .width(40)
          .onClick(() => {
            router.back();
          })
        Text('转盘抽签')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_main'))
      }
      .width('100%')
      .height(50)
      .padding({ left: 10, right: 16 })

      Scroll() {
        Column() {
          Text('今天吃什么？交给转盘')
            .fontSize(14)
            .fontColor($r('app.color.text_sub'))
            .margin({ top: 14, bottom: 18 })

          if (this.loading) {
            Column() {
              LoadingProgress().width(40).height(40).color($r('app.color.brand'))
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
          } else if (this.candidates.length === 0) {
            Column() {
              Text('🍽️')
                .fontSize(48)
              Text('暂无可抽菜品')
                .fontSize(15)
                .fontColor($r('app.color.text_sub'))
                .margin({ top: 10 })
              Button('重试')
                .width(120)
                .height(40)
                .margin({ top: 16 })
                .onClick(() => {
                  this.loadRandom();
                })
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
          } else {
            this.wheel()

            Button(this.spinning ? '转动中…' : '开始抽签')
              .width('70%')
              .height(52)
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_on_brand'))
              .backgroundColor(this.spinning ? $r('app.color.brand_bg') : $r('app.color.brand'))
              .borderRadius(26)
              .margin({ top: 28 })
              .onClick(() => {
                this.spin();
              })

            this.resultCard()

            Row() {
              Text('换一批')
                .fontSize(14)
                .fontColor($r('app.color.brand'))
            }
            .margin({ top: 18 })
            .onClick(() => {
              this.refreshBatch();
            })
          }
        }
        .width('100%')
        .padding({ bottom: 30 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_page'))
  }
}