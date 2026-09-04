import { router } from '@kit.ArkUI';
import { BizApi } from '../../service/BizApi';
import { BrowseHistoryVo } from '../../model/ApiModels';
import { DishCard } from '../../components/DishCard';
import { EmptyView } from '../../components/EmptyView';

/**
 * 浏览历史页（从「我的」进入）
 */
@Entry
@Component
struct HistoryPage {
  @State list: BrowseHistoryVo[] = [];
  @State loading: boolean = false;
  @State finished: boolean = false;
  private pageNum: number = 1;
  private pageSize: number = 10;

  aboutToAppear(): void {
    this.refresh();
  }

  refresh(): void {
    this.pageNum = 1;
    this.finished = false;
    this.loading = true;
    BizApi.historyPage(this.pageNum, this.pageSize).then((res) => {
      this.loading = false;
      if (res.code === 200 && res.data != null) {
        this.list = res.data.records;
        this.finished = this.list.length >= res.data.total;
      }
    });
  }

  loadMore(): void {
    if (this.loading || this.finished) {
      return;
    }
    this.pageNum++;
    this.loading = true;
    BizApi.historyPage(this.pageNum, this.pageSize).then((res) => {
      this.loading = false;
      if (res.code === 200 && res.data != null) {
        this.list = this.list.concat(res.data.records);
        this.finished = this.list.length >= res.data.total;
      }
    });
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor('#1A1A1A')
          .width(40)
          .onClick(() => {
            router.back();
          })
        Text('浏览历史')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .height(50)
      .padding({ left: 10, right: 16 })

      if (this.loading && this.list.length === 0) {
        Column() {
          LoadingProgress().width(36).height(36).color('#00A86B')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.list.length === 0) {
        EmptyView({ text: '暂无浏览记录' })
      } else {
        List({ space: 12 }) {
          ForEach(this.list, (h: BrowseHistoryVo) => {
            ListItem() {
              Column() {
                Text(`浏览于 ${h.browseTime}`)
                  .fontSize(11)
                  .fontColor('#BBBBBB')
                  .width('100%')
                  .margin({ bottom: 6 })
                DishCard({ dish: h.dish })
              }
              .width('100%')
            }
          }, (h: BrowseHistoryVo) => `${h.browseTime}_${h.dish.id}`)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 2, bottom: 12 })
        .scrollBar(BarState.Off)
        .onReachEnd(() => {
          this.loadMore();
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}