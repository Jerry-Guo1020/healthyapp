import { router, promptAction } from '@kit.ArkUI';
import { BizApi, DishQuery } from '../../service/BizApi';
import { DishVo } from '../../model/ApiModels';
import { DishCard } from '../../components/DishCard';
import { EmptyView } from '../../components/EmptyView';

/**
 * 搜索页：独立搜索界面，支持关键词搜索 + 一键清除 + 结果分页展示。
 * 从首页顶部搜索框点击进入。
 */
@Entry
@Component
struct SearchPage {
  @State keyword: string = '';
  @State dishes: DishVo[] = [];
  @State loading: boolean = false;
  @State finished: boolean = false;
  @State searched: boolean = false;
  private pageNum: number = 1;
  private pageSize: number = 10;
  private searchCtrl: TextInputController = new TextInputController();

  doSearch(): void {
    if (this.keyword.trim() === '') {
      promptAction.showToast({ message: '请输入搜索关键词' });
      return;
    }
    this.pageNum = 1;
    this.finished = false;
    this.loading = true;
    this.searched = true;
    const q = new DishQuery();
    q.pageNum = this.pageNum;
    q.pageSize = this.pageSize;
    q.keyword = this.keyword;
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
    q.keyword = this.keyword;
    BizApi.pageDishes(q).then((res) => {
      this.loading = false;
      if (res.code === 200 && res.data != null) {
        this.dishes = this.dishes.concat(res.data.records);
        this.finished = this.dishes.length >= res.data.total;
      }
    });
  }

  clearKeyword(): void {
    this.keyword = '';
    this.dishes = [];
    this.searched = false;
  }

  build() {
    Column() {
      // 顶部：返回 + 搜索框（含一键清除）
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor($r('app.color.text_main'))
          .width(36)
          .onClick(() => {
            router.back();
          })
        Row() {
          Text('🔍')
            .fontSize(15)
          TextInput({ placeholder: '搜索菜品名称', text: this.keyword, controller: this.searchCtrl })
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('#00000000')
            .onChange((value: string) => {
              this.keyword = value;
            })
          if (this.keyword !== '') {
            Text('✕')
              .fontSize(16)
              .fontColor($r('app.color.text_sub'))
              .width(30)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.clearKeyword();
              })
          }
          Text('搜索')
            .fontSize(14)
            .fontColor($r('app.color.text_on_brand'))
            .backgroundColor($r('app.color.brand'))
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .borderRadius(18)
            .margin({ left: 8 })
            .onClick(() => {
              this.searchCtrl.stopEditing();
              this.doSearch();
            })
        }
        .layoutWeight(1)
        .height(42)
        .padding({ left: 12, right: 6 })
        .backgroundColor($r('app.color.bg_input'))
        .borderRadius(21)
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 12, top: 8, bottom: 6 })

      if (!this.searched) {
        Column() {
          Text('🔎')
            .fontSize(48)
          Text('输入关键词搜索你想要的菜品')
            .fontSize(14)
            .fontColor($r('app.color.text_sub'))
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.loading && this.dishes.length === 0) {
        Column() {
          LoadingProgress().width(36).height(36).color($r('app.color.brand'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.dishes.length === 0) {
        EmptyView({ text: `未找到与「${this.keyword}」相关的菜品` })
      } else {
        Column() {
          Text(`「${this.keyword}」共 ${this.dishes.length} 道`)
            .fontSize(13)
            .fontColor($r('app.color.text_sub'))
            .width('100%')
            .padding({ left: 16, right: 16, top: 10, bottom: 4 })
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
        .width('100%')
        .layoutWeight(1)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_page'))
  }
}