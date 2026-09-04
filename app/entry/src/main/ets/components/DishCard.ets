import { router } from '@kit.ArkUI';
import { DishVo } from '../model/ApiModels';

// 详情页路由参数（ArkTS 禁止无类型对象字面量）
class DishDetailParams {
  dishId: string = '';
  name: string = '';
}

/**
 * 菜品卡片（首页 / 收藏 / 历史 复用）
 */
@Component
export struct DishCard {
  @Prop dish: DishVo = new DishVo();

  private openDetail(): void {
    const p = new DishDetailParams();
    p.dishId = this.dish.id;
    p.name = this.dish.name;
    router.pushUrl({
      url: 'pages/dish/DishDetailPage',
      params: p
    });
  }

  build() {
    Row() {
      if (this.dish.coverUrl !== '') {
        Image(this.dish.coverUrl)
          .width(94)
          .height(94)
          .borderRadius(10)
          .objectFit(ImageFit.Cover)
      } else {
        Text('🍽️')
          .width(94)
          .height(94)
          .fontSize(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#EAF5EF')
          .borderRadius(10)
      }

      Column() {
        Text(this.dish.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        if (this.dish.description !== '') {
          Text(this.dish.description)
            .fontSize(12)
            .fontColor('#999999')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ top: 4 })
        }

        if (this.dish.tags.length > 0) {
          Row({ space: 5 }) {
            ForEach(this.dish.tags.slice(0, 3), (tag: string) => {
              Text(tag)
                .fontSize(10)
                .fontColor('#00A86B')
                .backgroundColor('#00A86B14')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
            }, (tag: string) => tag)
          }
          .width('100%')
          .margin({ top: 6 })
        }

        Row() {
          Text(`${this.dish.calorie} 千卡`)
            .fontSize(12)
            .fontColor('#F5A623')
          Blank()
          Text(`❤ ${this.dish.favoriteCount}`)
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .margin({ top: 8 })
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
      this.openDetail();
    })
  }
}