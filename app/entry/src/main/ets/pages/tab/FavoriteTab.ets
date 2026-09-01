import { BizApi } from '../../service/BizApi';
import { DishVo } from '../../model/ApiModels';
import { DishCard } from '../../components/DishCard';
import { EmptyView } from '../../components/EmptyView';

/**
 * 收藏 Tab
 */
@Component
export struct FavoriteTab {
  @Prop @Watch('onActiveChange') active: boolean = false;
  @State dishes: DishVo[] = [];
  @State loading: boolean = false;
  @State finished: boolean = false;
  private pageNum: number = 1;
  private pageSize: number = 10;

  aboutToAppear(): void {
    this.refresh();
  }

  onActiveChange(): void {
    if (this.active) {
      this.refresh();
    }
  }

  refresh(): void {
    this.pageNum = 1;
    this.finished = false;
    this.loading = true;
    BizApi.favoritePage(this.pageNum, this.pageSize).then((res) => {
      this.loading = false;
      if (res.code === 200 && res.data != null) {
        this.dishes = res.data.records;
        this.finished = this.dishes.length >= res.data.total;
      }
    });
  }

  loadMore(): void {
    if (this.loading || this.finished) {
      return;
    }
    this.pageNum++;
    this.loading = true;
    BizApi.favoritePage(this.pageNum, this.pageSize).then((res) => {
      this.loading = false;
      if (res.code === 200 && res.data != null) {
        this.dishes = this.dishes.concat(res.data.records);
        this.finished = this.dishes.length >= res.data.total;
      }
    });
  }

  build() {
    Column() {
      Row() {
        Text('我的收藏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 12 })

      if (this.loading && this.dishes.length === 0) {
        Column() {
          LoadingProgress().width(36).height(36).color('#00A86B')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.dishes.length === 0) {
        EmptyView({ text: '还没有收藏，去首页逛逛吧' })
      } else {
        List({ space: 12 }) {
          ForEach(this.dishes, (d: DishVo) => {
            ListItem() {
              DishCard({ dish: d })
            }
          }, (d: DishVo) => d.id)
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