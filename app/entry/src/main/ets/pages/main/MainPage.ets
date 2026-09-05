import { HomeTab } from '../tab/HomeTab';
import { FoodRecognizeTab } from '../tab/FoodRecognizeTab';
import { HealthTab } from '../tab/HealthTab';
import { ProfileTab } from '../tab/ProfileTab';
import { AppIcons } from '../../common/Icons';

/**
 * 主框架：底部四 Tab（首页 / 识食 / 健康 / 我的）
 * 收藏、历史已移入「我的」作为子功能；拍照识食提升为底部主功能。
 */
@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;

  @Builder
  tabBar(title: string, icon: string, index: number) {
    Column() {
      // 图标：emoji 占位（无法着色）；替换为 PNG 后，选中/未选中通过 currentIndex 切换两套图标
      Text(icon)
        .fontSize(this.currentIndex === index ? 22 : 20)
      Text(title)
        .fontSize(11)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? $r('app.color.brand') : $r('app.color.text_sub'))
        .margin({ top: 2 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        HomeTab()
      }
      .tabBar(this.tabBar('首页', AppIcons.TAB_HOME, 0))

      TabContent() {
        FoodRecognizeTab()
      }
      .tabBar(this.tabBar('识食', AppIcons.TAB_FOOD, 1))

      TabContent() {
        HealthTab({ active: this.currentIndex === 2 })
      }
      .tabBar(this.tabBar('健康', AppIcons.TAB_HEALTH, 2))

      TabContent() {
        ProfileTab({ active: this.currentIndex === 3 })
      }
      .tabBar(this.tabBar('我的', AppIcons.TAB_PROFILE, 3))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .scrollable(false)
    .barBackgroundColor($r('app.color.bg_card'))
  }
}