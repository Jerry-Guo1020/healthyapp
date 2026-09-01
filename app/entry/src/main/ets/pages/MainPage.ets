import { HomeTab } from './tab/HomeTab';
import { FavoriteTab } from './tab/FavoriteTab';
import { HistoryTab } from './tab/HistoryTab';
import { ProfileTab } from './tab/ProfileTab';

/**
 * 主框架：底部四 Tab（首页 / 收藏 / 历史 / 我的）
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
        FavoriteTab({ active: this.currentIndex === 1 })
      }
      .tabBar(this.tabBar('收藏', '❤️'))

      TabContent() {
        HistoryTab({ active: this.currentIndex === 2 })
      }
      .tabBar(this.tabBar('历史', '🕒'))

      TabContent() {
        ProfileTab({ active: this.currentIndex === 3 })
      }
      .tabBar(this.tabBar('我的', '👤'))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .scrollable(false)
    .barBackgroundColor('#FFFFFF')
  }
}