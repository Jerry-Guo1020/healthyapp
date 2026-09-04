import { router, promptAction } from '@kit.ArkUI';
import { BizApi } from '../../service/BizApi';
import { DishVo } from '../../model/ApiModels';
import { COLOR_PRIMARY } from '../../common/Constants';
import { AuthGuard } from '../../common/AuthGuard';

/**
 * 菜品详情页
 */
@Entry
@Component
struct DishDetailPage {
  @State dish: DishVo = new DishVo();
  @State favorite: boolean = false;
  @State favoriteCount: number = 0;
  @State loading: boolean = true;
  private dishId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params != null && params['dishId'] != null) {
      this.dishId = params['dishId'] as string;
      this.loadDetail();
    }
  }

  loadDetail(): void {
    BizApi.dishDetail(this.dishId).then((res) => {
      this.loading = false;
      if (res.code === 200 && res.data != null) {
        this.dish = res.data;
        this.favorite = res.data.favorite;
        this.favoriteCount = res.data.favoriteCount;
        // 记录浏览（异步，不阻塞）
        BizApi.recordHistory(this.dishId);
      }
    });
  }

  toggleFavorite(): void {
    if (!AuthGuard.requireAccount()) {
      return;
    }
    if (this.favorite) {
      BizApi.removeFavorite(this.dish.id).then((res) => {
        if (res.code === 200) {
          this.favorite = false;
          this.favoriteCount = this.favoriteCount > 0 ? this.favoriteCount - 1 : 0;
          promptAction.showToast({ message: '已取消收藏' });
        }
      });
    } else {
      BizApi.addFavorite(this.dish.id).then((res) => {
        if (res.code === 200) {
          this.favorite = true;
          this.favoriteCount++;
          promptAction.showToast({ message: '已收藏' });
        }
      });
    }
  }

  goBack(): void {
    router.back();
  }

  @Builder
  tagChipBuilder(text: string) {
    Text(text)
      .fontSize(11)
      .fontColor('#00A86B')
      .backgroundColor('#00A86B14')
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(6)
  }

  build() {
    Column() {
      Stack() {
        if (this.dish.coverUrl !== '') {
          Image(this.dish.coverUrl)
            .width('100%')
            .height(240)
            .objectFit(ImageFit.Cover)
        } else {
          Column() {
            Text('🍽️')
              .fontSize(72)
          }
          .width('100%')
          .height(240)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#EAF5EF')
        }
        // 返回按钮
        Text('‹')
          .width(38)
          .height(38)
          .fontSize(26)
          .textAlign(TextAlign.Center)
          .backgroundColor('#66000000')
          .fontColor('#FFFFFF')
          .borderRadius(19)
          .position({ x: 14, y: 14 })
          .onClick(() => {
            this.goBack();
          })
      }
      .width('100%')
      .height(240)

      if (this.loading) {
        Column() {
          LoadingProgress().width(40).height(40).color(COLOR_PRIMARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 基本信息
            Column() {
              Row() {
                Text(this.dish.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                  .layoutWeight(1)
                Text(`❤ ${this.favoriteCount}`)
                  .fontSize(13)
                  .fontColor('#999999')
              }
              .width('100%')

              Row({ space: 6 }) {
                this.tagChipBuilder(`${this.dish.calorie} 千卡`)
                if (this.dish.spicyLevel > 0) {
                  this.tagChipBuilder(`辣度 ${this.dish.spicyLevel}`)
                }
                if (this.dish.isLight === 1) {
                  this.tagChipBuilder('清淡')
                }
                if (this.dish.isWarm === 1) {
                  this.tagChipBuilder('温热')
                }
                if (this.dish.isEasyDigest === 1) {
                  this.tagChipBuilder('易消化')
                }
              }
              .width('100%')
              .margin({ top: 10 })

              if (this.dish.tags.length > 0) {
                Row({ space: 6 }) {
                  ForEach(this.dish.tags, (t: string) => {
                    this.tagChipBuilder(t)
                  }, (t: string) => t)
                }
                .width('100%')
                .margin({ top: 8 })
              }
            }
            .width('92%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
            .margin({ top: 14 })

            // 描述
            if (this.dish.description !== '') {
              Column() {
                Text('菜品介绍')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1A1A')
                Text(this.dish.description)
                  .fontSize(14)
                  .fontColor('#666666')
                  .lineHeight(22)
                  .margin({ top: 8 })
                  .width('100%')
              }
              .width('92%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(14)
              .margin({ top: 12 })
              .alignItems(HorizontalAlign.Start)
            }

            // 食材
            if (this.dish.ingredients !== '') {
              Column() {
                Text('主要食材')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1A1A')
                Text(this.dish.ingredients)
                  .fontSize(14)
                  .fontColor('#666666')
                  .lineHeight(22)
                  .margin({ top: 8 })
                  .width('100%')
              }
              .width('92%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(14)
              .margin({ top: 12 })
              .alignItems(HorizontalAlign.Start)
            }

            // 营养指标
            Column() {
              Text('营养与口味')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
              Row({ space: 10 }) {
                this.metricItem('热量', `${this.dish.calorie} 千卡`)
                this.metricItem('辣度', this.dish.spicyLevel > 0 ? `⭐${this.dish.spicyLevel}` : '不辣')
                this.metricItem('油量', this.oilText())
              }
              .width('100%')
              .margin({ top: 12 })

              if (this.dish.protein > 0 || this.dish.fat > 0 || this.dish.carbs > 0) {
                Row({ space: 10 }) {
                  this.metricItem('蛋白质', `${this.dish.protein} g`)
                  this.metricItem('脂肪', `${this.dish.fat} g`)
                  this.metricItem('碳水', `${this.dish.carbs} g`)
                }
                .width('100%')
                .margin({ top: 12 })
                Text('* 三大营养素为每100g含量')
                  .fontSize(10)
                  .fontColor('#BBBBBB')
                  .margin({ top: 6 })
                  .width('100%')
              } else {
                Text('三大营养素暂未录入，可在管理端「联网补全」')
                  .fontSize(11)
                  .fontColor('#BBBBBB')
                  .margin({ top: 10 })
                  .width('100%')
              }
            }
            .width('92%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
            .margin({ top: 12, bottom: 90 })
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // 底部操作栏
      Row() {
        Button(this.favorite ? '❤ 已收藏' : '🤍 收藏')
          .width('100%')
          .height(46)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor(this.favorite ? '#E5484D' : COLOR_PRIMARY)
          .onClick(() => {
            this.toggleFavorite();
          })
      }
      .width('100%')
      .height(66)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }

  private oilText(): string {
    if (this.dish.oilLevel <= 0) {
      return '少油';
    }
    if (this.dish.oilLevel === 1) {
      return '少油';
    }
    if (this.dish.oilLevel === 2) {
      return '适中';
    }
    return '偏多';
  }

  @Builder
  metricItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#999999')
      Text(value)
        .fontSize(14)
        .fontColor('#1A1A1A')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
  }
}