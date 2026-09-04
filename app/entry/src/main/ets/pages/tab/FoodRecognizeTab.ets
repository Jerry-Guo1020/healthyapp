import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { FoodApi } from '../service/FoodApi';
import { ImageUtil } from '../common/ImageUtil';
import { FoodRecognizeVo, DishVo } from '../model/ApiModels';
import { DishCard } from '../components/DishCard';

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
  imageArea() {
    Column() {
      if (this.imageUri !== '') {
        Image(this.imageUri)
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Contain)
          .borderRadius(12)
          .backgroundColor('#FFFFFF')
        Row({ space: 10 }) {
          Button('重新选择')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .fontColor('#555555')
            .backgroundColor('#F0F2F3')
            .borderRadius(20)
            .onClick(() => {
              this.pickImage();
            })
          Button(this.recognizing ? '识别中...' : '开始识别')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#00A86B')
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
            .fontColor('#999999')
            .margin({ top: 10 })
          Button('选择图片')
            .height(42)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#00A86B')
            .borderRadius(20)
            .margin({ top: 16 })
            .onClick(() => {
              this.pickImage();
            })
        }
        .width('100%')
        .height(220)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
      }
    }
    .width('92%')
    .margin({ top: 8 })
  }

  @Builder
  resultArea() {
    Column() {
      Text('识别结果')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .width('100%')

      Row() {
        Text(this.result!.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        Blank()
        if (this.result!.hasCalorie && this.result!.calorie !== '') {
          Text(this.result!.calorie)
            .fontSize(13)
            .fontColor('#F5A623')
        }
      }
      .width('100%')
      .margin({ top: 12 })

      if (this.result!.matchedDish != null) {
        Text('已匹配到膳衡菜品')
          .fontSize(13)
          .fontColor('#00A86B')
          .width('100%')
          .margin({ top: 14, bottom: 8 })
        DishCard({ dish: this.result!.matchedDish })
      } else {
        Text('未匹配到本地菜品，为你推荐以下健康选择')
          .fontSize(13)
          .fontColor('#999999')
          .width('100%')
          .margin({ top: 14, bottom: 8 })
      }

      if (this.result!.recommends.length > 0) {
        Text('为你推荐')
          .fontSize(13)
          .fontColor('#1A1A1A')
          .width('100%')
          .margin({ top: 14, bottom: 8 })
        Column({ space: 10 }) {
          ForEach(this.result!.recommends, (item: DishVo) => {
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
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 8 })

      Scroll() {
        Column() {
          this.imageArea()
          if (this.result != null) {
            this.resultArea()
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
    .backgroundColor('#F5F6F7')
  }
}