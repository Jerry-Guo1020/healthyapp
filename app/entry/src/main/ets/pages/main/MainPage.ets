import { HomeTab } from '../tab/HomeTab';
import { FoodRecognizeTab } from '../tab/FoodRecognizeTab';
import { HealthTab } from '../tab/HealthTab';
import { ProfileTab } from '../tab/ProfileTab';

/**
 * 主框架：底部四 Tab（首页 / 识食 / 健康 / 我的）
 * 收藏、历史已移入「我的」作为子功能；拍照识食提升为底部主功能。
 */
@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;

  @Builder
  tabBar(title: string, icon: string) {
    Column() {
      Text(icon)
        .fontSize(20)
      Text(title)
        .fontSize(11)
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
      .tabBar(this.tabBar('首页', '🏠'))

      TabContent() {
        FoodRecognizeTab()
      }
      .tabBar(this.tabBar('识食', '📷'))

      TabContent() {
        HealthTab({ active: this.currentIndex === 2 })
      }
      .tabBar(this.tabBar('健康', '🫀'))

      TabContent() {
        ProfileTab({ active: this.currentIndex === 3 })
      }
      .tabBar(this.tabBar('我的', '👤'))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .scrollable(false)
    .barBackgroundColor($r('app.color.bg_card'))
  }
}