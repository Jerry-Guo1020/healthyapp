import { router } from '@kit.ArkUI';
import { BizApi, DishQuery } from '../../service/BizApi';
import { CategoryVo, DishVo } from '../../model/ApiModels';
import { DishCard } from '../../components/DishCard';
import { EmptyView } from '../../components/EmptyView';

/**
 * 首页 Tab：搜索 + 分类 + 菜品列表
 */
@Component
export struct HomeTab {
  @State categories: CategoryVo[] = [];
  @State dishes: DishVo[] = [];
  @State selectedCategoryId: string = '';
  @State loading: boolean = false;
  @State finished: boolean = false;
  private pageNum: number = 1;
  private pageSize: number = 10;

  aboutToAppear(): void {
    this.loadCategories();
    this.refreshDishes();
  }

  loadCategories(): void {
    BizApi.listCategories().then((res) => {
      if (res.code === 200 && res.data != null) {
        this.categories = res.data;
      }
    });
  }

  refreshDishes(): void {
    this.pageNum = 1;
    this.finished = false;
    this.loading = true;
    const q = new DishQuery();
    q.pageNum = this.pageNum;
    q.pageSize = this.pageSize;
    q.categoryId = this.selectedCategoryId;
    q.keyword = '';
    BizApi.pageDishes(q).then((res) => {
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
    const q = new DishQuery();
    q.pageNum = this.pageNum;
    q.pageSize = this.pageSize;
    q.categoryId = this.selectedCategoryId;
    q.keyword = '';
    BizApi.pageDishes(q).then((res) => {
      this.loading = false;
      if (res.code === 200 && res.data != null) {
        this.dishes = this.dishes.concat(res.data.records);
        this.finished = this.dishes.length >= res.data.total;
      }
    });
  }

  onCategoryClick(id: string): void {
    if (this.selectedCategoryId === id) {
      return;
    }
    this.selectedCategoryId = id;
    this.refreshDishes();
  }

  @Builder
  categoryChip(name: string, id: string) {
    Text(name)
      .fontSize(14)
      .fontColor(this.selectedCategoryId === id ? $r('app.color.text_on_brand') : $r('app.color.text_mid'))
      .backgroundColor(this.selectedCategoryId === id ? $r('app.color.brand') : $r('app.color.bg_card'))
      .padding({ left: 14, right: 14, top: 7, bottom: 7 })
      .borderRadius(17)
      .onClick(() => {
        this.onCategoryClick(id);
      })
  }

  build() {
    Column() {
      Row() {
        Text('膳衡')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_main'))
        Text(' 健康饮食 · 膳衡相伴')
          .fontSize(13)
          .fontColor($r('app.color.text_sub'))
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 10 })

      Row() {
        Text('🔍')
          .fontSize(15)
        Text('搜索菜品名称')
          .fontSize(14)
          .fontColor($r('app.color.text_sub'))
          .layoutWeight(1)
          .margin({ left: 8 })
        Text('搜索')
          .fontSize(13)
          .fontColor($r('app.color.brand'))
      }
      .width('92%')
      .height(42)
      .padding({ left: 12, right: 12 })
      .backgroundColor($r('app.color.bg_input'))
      .borderRadius(21)
      .margin({ bottom: 10 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/search/SearchPage' });
      })

      Row() {
        Text('🎡')
          .fontSize(20)
        Text('转盘抽签')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_on_brand'))
          .margin({ left: 8 })
        Blank()
        Text('纠结？转一转决定吃什么 ›')
          .fontSize(12)
          .fontColor('#FDE9C8')
      }
      .width('92%')
      .height(44)
      .padding({ left: 14, right: 14 })
      .backgroundColor($r('app.color.orange'))
      .borderRadius(12)
      .margin({ bottom: 10 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/wheel/WheelPage' });
      })

      Scroll() {
        Row({ space: 10 }) {
          this.categoryChip('全部', '')
          ForEach(this.categories, (c: CategoryVo) => {
            this.categoryChip(c.name, c.id)
          }, (c: CategoryVo) => c.id)
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(44)
      .margin({ bottom: 8 })

      if (this.loading && this.dishes.length === 0) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color($r('app.color.brand'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.dishes.length === 0) {
        EmptyView({ text: '暂无菜品，请先到管理端添加菜品' })
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
    .backgroundColor($r('app.color.bg_page'))
  }
}