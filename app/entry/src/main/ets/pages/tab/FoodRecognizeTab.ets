import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { FoodApi } from '../../service/FoodApi';
import { ImageUtil } from '../../common/ImageUtil';
import { FoodRecognizeVo, DishVo } from '../../model/ApiModels';
import { DishCard } from '../../components/DishCard';

const TAG: string = 'FoodRecognizeTab';

/**
 * 拍照识食 Tab（底部导航主功能）：选图 → 压缩转 base64 → 后端识别 → 匹配菜品 + 推荐
 */
@Component
export struct FoodRecognizeTab {
  @State imageUri: string = '';
  @State imageBase64: string = '';
  @State recognizing: boolean = false;
  @State result: FoodRecognizeVo | null = null;

  pickImage(): void {
    const picker = new photoAccessHelper.PhotoViewPicker();
    const options = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 1;
    picker.select(options).then((res: photoAccessHelper.PhotoSelectResult) => {
      if (res.photoUris.length > 0) {
        this.imageUri = res.photoUris[0];
        this.imageBase64 = '';
        this.result = null;
      }
    }).catch((err: BusinessError) => {
      promptAction.showToast({ message: '选择图片失败' });
    });
  }

  async recognize(): Promise<void> {
    if (this.recognizing || this.imageUri === '') {
      return;
    }
    this.recognizing = true;
    try {
      this.imageBase64 = await ImageUtil.toBase64(this.imageUri);
      const res = await FoodApi.recognize(this.imageBase64);
      if (res.code === 200 && res.data != null) {
        this.result = res.data;
      }
    } finally {
      this.recognizing = false;
    }
  }

  @Builder
  stepItem(icon: string, label: string) {
    Column() {
      Text(icon)
        .fontSize(22)
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_mid'))
        .margin({ top: 6 })
    }
    .layoutWeight(1)
  }

  @Builder
  introCard() {
    Column() {
      Text('怎么使用')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_main'))
        .width('100%')
      Row() {
        this.stepItem('📷', '拍照 / 选图')
        Text('›')
          .fontSize(18)
          .fontColor($r('app.color.text_hint'))
        this.stepItem('🔍', '自动识别')
        Text('›')
          .fontSize(18)
          .fontColor($r('app.color.text_hint'))
        this.stepItem('🥗', '匹配推荐')
      }
      .width('100%')
      .margin({ top: 14 })
      Text('拍下食物照片，自动识别菜品名称与热量，并匹配膳衡菜品，给出更健康的选择。')
        .fontSize(12)
        .fontColor($r('app.color.text_sub'))
        .lineHeight(18)
        .width('100%')
        .margin({ top: 12 })
      Text('• 支持常见中式菜品、主食、水果等\n• 照片仅用于本次识别，不会长期存储')
        .fontSize(11)
        .fontColor($r('app.color.text_hint'))
        .lineHeight(18)
        .width('100%')
        .margin({ top: 10 })
    }
    .width('92%')
    .padding(16)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(14)
    .margin({ top: 8 })
  }

  @Builder
  imageArea() {
    Column() {
      if (this.imageUri !== '') {
        Image(this.imageUri)
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Contain)
          .borderRadius(12)
          .backgroundColor($r('app.color.bg_card'))
        Row({ space: 10 }) {
          Button('重新选择')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .fontColor($r('app.color.text_mid'))
            .backgroundColor($r('app.color.bg_chip'))
            .borderRadius(20)
            .onClick(() => {
              this.pickImage();
            })
          Button(this.recognizing ? '识别中...' : '开始识别')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .fontColor($r('app.color.text_on_brand'))
            .backgroundColor($r('app.color.brand'))
            .borderRadius(20)
            .enabled(!this.recognizing)
            .onClick(() => {
              this.recognize();
            })
        }
        .width('100%')
        .margin({ top: 12 })
      } else {
        Column() {
          Text('📷')
            .fontSize(50)
          Text('拍摄或选择一张食物照片')
            .fontSize(14)
            .fontColor($r('app.color.text_sub'))
            .margin({ top: 10 })
          Button('选择图片')
            .height(42)
            .fontSize(14)
            .fontColor($r('app.color.text_on_brand'))
            .backgroundColor($r('app.color.brand'))
            .borderRadius(20)
            .margin({ top: 16 })
            .onClick(() => {
              this.pickImage();
            })
        }
        .width('100%')
        .height(220)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.bg_card'))
        .borderRadius(12)
      }
    }
    .width('92%')
    .margin({ top: 8 })
  }

  @Builder
  resultArea(r: FoodRecognizeVo) {
    Column() {
      Text('识别结果')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_main'))
        .width('100%')

      Row() {
        Text(r.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_main'))
        Blank()
        if (r.hasCalorie && r.calorie !== '') {
          Text(r.calorie)
            .fontSize(13)
            .fontColor($r('app.color.orange'))
        }
      }
      .width('100%')
      .margin({ top: 12 })

      if (r.matchedDish != null) {
        Text('已匹配到膳衡菜品')
          .fontSize(13)
          .fontColor($r('app.color.brand'))
          .width('100%')
          .margin({ top: 14, bottom: 8 })
        DishCard({ dish: r.matchedDish })
      } else {
        Text('未匹配到本地菜品，为你推荐以下健康选择')
          .fontSize(13)
          .fontColor($r('app.color.text_sub'))
          .width('100%')
          .margin({ top: 14, bottom: 8 })
      }

      if (r.recommends.length > 0) {
        Text('为你推荐')
          .fontSize(13)
          .fontColor($r('app.color.text_main'))
          .width('100%')
          .margin({ top: 14, bottom: 8 })
        Column({ space: 10 }) {
          ForEach(r.recommends, (item: DishVo) => {
            DishCard({ dish: item })
          }, (item: DishVo) => item.id)
        }
        .width('100%')
      }
    }
    .width('92%')
    .margin({ top: 16 })
  }

  build() {
    Column() {
      Row() {
        Text('拍照识食')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_main'))
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 8 })

      Scroll() {
        Column() {
          this.introCard()
          this.imageArea()
          if (this.result != null) {
            this.resultArea(this.result)
          }
        }
        .width('100%')
        .padding({ bottom: 20 })
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