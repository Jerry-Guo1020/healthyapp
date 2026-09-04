import { router, promptAction } from '@kit.ArkUI';
import { UserSession } from '../../common/UserSession';
import { HealthAuthState } from '../../common/HealthAuthState';
import { AuthGuard } from '../../common/AuthGuard';
import { UserApi, PreferenceBody, AvoidBody } from '../../service/UserApi';
import { HealthApi } from '../../service/HealthApi';
import { HuaweiHealthService } from '../../service/HuaweiHealthService';
import { AvoidVo } from '../../model/ApiModels';

// 健康目标选项（code + label；code 与后端 healthGoal 枚举一致）
const GOAL_CODES: string[] = ['LOSE_FAT', 'MUSCLE_GAIN', 'STOMACH', 'SUGAR_CONTROL'];
const GOAL_LABELS: string[] = ['减脂', '增肌', '养胃', '控糖'];
// 口味偏好选项（存 JSON 数组字符串）
const TASTE_OPTIONS: string[] = ['清淡', '微辣', '重口', '少油', '咸鲜'];
// 菜系偏好选项（存 JSON 数组字符串）
const CUISINE_OPTIONS: string[] = ['粤菜', '川菜', '家常菜', '轻食', '面食'];
// 忌口快捷项
const QUICK_AVOIDS: string[] = ['花生', '海鲜', '辣', '乳制品', '麸质', '羊肉'];

/**
 * 我的 Tab：用户信息 + 饮食偏好编辑 + 忌口管理 + 健康授权入口 + 关于
 */
@Component
export struct ProfileTab {
  @Prop @Watch('onActiveChange') active: boolean = false;
  @State nickname: string = '未登录';
  @State isGuest: number = 1;

  // 饮食偏好
  @State healthGoal: string = '';
  @State tasteSel: string[] = [];
  @State cuisineSel: string[] = [];
  @State budgetMinText: string = '';
  @State budgetMaxText: string = '';
  @State prefExpanded: boolean = false;
  @State savingPref: boolean = false;

  // 忌口
  @State avoidList: AvoidVo[] = [];
  @State avoidInput: string = '';
  @State avoidAdding: boolean = false;

  // 健康授权
  @State authStatus: number = 0;
  @State authorizing: boolean = false;

  aboutToAppear(): void {
    this.refreshAll();
  }

  onActiveChange(): void {
    if (this.active) {
      this.refreshAll();
    }
  }

  refreshAll(): void {
    this.refreshUser();
    this.refreshAuthState();
    this.loadPreference();
    this.loadAvoid();
  }

  refreshAuthState(): void {
    this.authStatus = HealthAuthState.isAuthorized() ? 1 : 0;
  }

  refreshUser(): void {
    const u = UserSession.userInfo;
    if (u != null) {
      this.nickname = u.nickname;
      this.isGuest = u.isGuest;
    } else {
      this.nickname = '未登录';
      this.isGuest = 1;
    }
  }

  loadPreference(): void {
    UserApi.getPreference().then((res) => {
      if (res.code === 200 && res.data != null) {
        const p = res.data;
        this.healthGoal = p.healthGoal;
        this.tasteSel = this.parseArray(p.tastePreference);
        this.cuisineSel = this.parseArray(p.cuisinePreference);
        this.budgetMinText = p.budgetMin > 0 ? p.budgetMin.toString() : '';
        this.budgetMaxText = p.budgetMax > 0 ? p.budgetMax.toString() : '';
      }
    });
  }

  private parseArray(s: string): string[] {
    if (s === '') {
      return [];
    }
    return JSON.parse(s) as string[];
  }

  loadAvoid(): void {
    UserApi.listAvoid().then((res) => {
      if (res.code === 200 && res.data != null) {
        this.avoidList = res.data;
      }
    });
  }

  savePreference(): void {
    if (this.savingPref) {
      return;
    }
    this.savingPref = true;
    const b = new PreferenceBody();
    b.healthGoal = this.healthGoal;
    b.tastePreference = JSON.stringify(this.tasteSel);
    b.cuisinePreference = JSON.stringify(this.cuisineSel);
    b.budgetMin = this.budgetMinText === '' ? 0 : Number(this.budgetMinText);
    b.budgetMax = this.budgetMaxText === '' ? 0 : Number(this.budgetMaxText);
    UserApi.savePreference(b).then((res) => {
      this.savingPref = false;
      if (res.code === 200) {
        promptAction.showToast({ message: '偏好已保存' });
        this.prefExpanded = false;
      }
    });
  }

  addAvoid(item: string): void {
    const name = item.trim();
    if (name === '') {
      promptAction.showToast({ message: '请输入忌口项' });
      return;
    }
    if (this.avoidAdding) {
      return;
    }
    this.avoidAdding = true;
    const b = new AvoidBody();
    b.avoidType = 'AVOID';
    b.itemName = name;
    UserApi.addAvoid(b).then((res) => {
      this.avoidAdding = false;
      if (res.code === 200) {
        this.avoidInput = '';
        this.loadAvoid();
      }
    });
  }

  removeAvoid(id: string): void {
    UserApi.removeAvoid(id).then((res) => {
      if (res.code === 200) {
        this.loadAvoid();
      }
    });
  }

  confirmAuthorize(): void {
    this.getUIContext().showAlertDialog({
      title: '健康数据授权',
      message: '将授权读取：步数、睡眠、心率、压力、日常活动数据，用于生成个性化饮食推荐。你可随时在本页取消授权。',
      primaryButton: {
        value: '同意授权',
        action: () => {
          this.authorizeHealth();
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {
        }
      }
    });
  }

  authorizeHealth(): void {
    if (this.authorizing) {
      return;
    }
    if (!AuthGuard.requireAccount()) {
      return;
    }
    const ctx = this.getUIContext().getHostContext();
    if (ctx === undefined) {
      promptAction.showToast({ message: '无法获取应用上下文' });
      return;
    }
    this.authorizing = true;
    HuaweiHealthService.syncAndArchive(ctx).then((r) => {
      this.authorizing = false;
      this.authStatus = HealthAuthState.isAuthorized() ? 1 : 0;
      if (r.success) {
        promptAction.showToast({ message: '已授权并同步运动健康' });
      } else {
        promptAction.showToast({ message: r.message });
      }
    });
  }

  confirmRevoke(): void {
    this.getUIContext().showAlertDialog({
      title: '取消健康授权',
      message: '取消后将不再使用你的健康数据生成推荐，确定取消吗？',
      primaryButton: {
        value: '确定取消',
        action: () => {
          this.revokeHealth();
        }
      },
      secondaryButton: {
        value: '再想想',
        action: () => {
        }
      }
    });
  }

  revokeHealth(): void {
    if (this.authorizing) {
      return;
    }
    this.authorizing = true;
    HealthApi.revokeAuth().then((res) => {
      this.authorizing = false;
      if (res.code === 200) {
        HealthAuthState.setAuthorized(false);
        this.authStatus = 0;
        promptAction.showToast({ message: '已取消授权' });
      }
    });
  }

  enterFavorite(): void {
    if (!AuthGuard.requireAccount()) {
      return;
    }
    router.pushUrl({ url: 'pages/FavoritePage' });
  }

  enterHistory(): void {
    if (!AuthGuard.requireAccount()) {
      return;
    }
    router.pushUrl({ url: 'pages/HistoryPage' });
  }

  enterAccount(): void {
    router.pushUrl({ url: 'pages/AccountManagePage' });
  }

  enterAbout(): void {
    router.pushUrl({ url: 'pages/AboutPage' });
  }

  onLogout(): void {
    UserSession.logout();
    promptAction.showToast({ message: '已退出登录' });
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  selectGoal(code: string): void {
    this.healthGoal = this.healthGoal === code ? '' : code;
  }

  toggleTaste(name: string): void {
    if (this.tasteSel.indexOf(name) >= 0) {
      this.tasteSel = this.tasteSel.filter((x: string) => x !== name);
    } else {
      this.tasteSel = this.tasteSel.concat([name]);
    }
  }

  toggleCuisine(name: string): void {
    if (this.cuisineSel.indexOf(name) >= 0) {
      this.cuisineSel = this.cuisineSel.filter((x: string) => x !== name);
    } else {
      this.cuisineSel = this.cuisineSel.concat([name]);
    }
  }

  inList(arr: string[], name: string): boolean {
    return arr.indexOf(name) >= 0;
  }

  goalText(code: string): string {
    const idx = GOAL_CODES.indexOf(code);
    return idx >= 0 ? GOAL_LABELS[idx] : code;
  }

  goalSummary(): string {
    if (this.healthGoal === '') {
      return '未设置';
    }
    return this.goalText(this.healthGoal);
  }

  // ===================== 组件 =====================

  @Builder
  goalChip(code: string) {
    Text(this.goalText(code))
      .fontSize(13)
      .fontColor(this.healthGoal === code ? '#FFFFFF' : '#555555')
      .backgroundColor(this.healthGoal === code ? '#00A86B' : '#F0F2F3')
      .padding({ left: 14, right: 14, top: 7, bottom: 7 })
      .borderRadius(16)
      .onClick(() => {
        this.selectGoal(code);
      })
  }

  @Builder
  tasteChip(name: string) {
    Text(name)
      .fontSize(13)
      .fontColor(this.inList(this.tasteSel, name) ? '#FFFFFF' : '#555555')
      .backgroundColor(this.inList(this.tasteSel, name) ? '#00A86B' : '#F0F2F3')
      .padding({ left: 14, right: 14, top: 7, bottom: 7 })
      .borderRadius(16)
      .onClick(() => {
        this.toggleTaste(name);
      })
  }

  @Builder
  cuisineChip(name: string) {
    Text(name)
      .fontSize(13)
      .fontColor(this.inList(this.cuisineSel, name) ? '#FFFFFF' : '#555555')
      .backgroundColor(this.inList(this.cuisineSel, name) ? '#00A86B' : '#F0F2F3')
      .padding({ left: 14, right: 14, top: 7, bottom: 7 })
      .borderRadius(16)
      .onClick(() => {
        this.toggleCuisine(name);
      })
  }

  @Builder
  avoidChip(v: AvoidVo) {
    Row() {
      Text(v.itemName)
        .fontSize(13)
        .fontColor('#1A1A1A')
      Text(' ✕')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ left: 4 })
    }
    .padding({ left: 12, right: 12, top: 7, bottom: 7 })
    .backgroundColor('#F0F2F3')
    .borderRadius(16)
    .onClick(() => {
      this.removeAvoid(v.id);
    })
  }

  @Builder
  quickAvoidChip(name: string) {
    Text('+ ' + name)
      .fontSize(13)
      .fontColor('#00A86B')
      .backgroundColor('#00A86B12')
      .padding({ left: 12, right: 12, top: 7, bottom: 7 })
      .borderRadius(16)
      .onClick(() => {
        this.addAvoid(name);
      })
  }

  @Builder
  groupLabel(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor('#1A1A1A')
      .width('100%')
      .margin({ top: 14 })
  }

  @Builder
  userCard() {
    Row() {
      Text('👤')
        .width(60)
        .height(60)
        .fontSize(30)
        .textAlign(TextAlign.Center)
        .backgroundColor('#00A86B1A')
        .borderRadius(30)
      Column() {
        Text(this.nickname)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        Text(this.isGuest === 1 ? '游客模式（登录后可同步数据）' : '已登录用户')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })
    }
    .width('92%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 6 })
  }

  @Builder
  menuCard() {
    Column() {
      Row() {
        Text('❤️')
          .fontSize(18)
        Text('我的收藏')
          .fontSize(15)
          .fontColor('#1A1A1A')
          .margin({ left: 12 })
        Blank()
        Text('›')
          .fontSize(16)
          .fontColor('#BBBBBB')
      }
      .width('100%')
      .height(48)
      .onClick(() => {
        this.enterFavorite();
      })

      Divider().color('#F0F0F0')

      Row() {
        Text('🕒')
          .fontSize(18)
        Text('浏览历史')
          .fontSize(15)
          .fontColor('#1A1A1A')
          .margin({ left: 12 })
        Blank()
        Text('›')
          .fontSize(16)
          .fontColor('#BBBBBB')
      }
      .width('100%')
      .height(48)
      .onClick(() => {
        this.enterHistory();
      })

      Divider().color('#F0F0F0')

      Row() {
        Text('👤')
          .fontSize(18)
        Text('用户管理')
          .fontSize(15)
          .fontColor('#1A1A1A')
          .margin({ left: 12 })
        Blank()
        Text('›')
          .fontSize(16)
          .fontColor('#BBBBBB')
      }
      .width('100%')
      .height(48)
      .onClick(() => {
        this.enterAccount();
      })
    }
    .width('92%')
    .padding({ left: 18, right: 18, top: 6, bottom: 6 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 12 })
  }

  @Builder
  preferenceCard() {
    Column() {
      Row() {
        Text('饮食偏好')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        Blank()
        Text(this.prefExpanded ? '收起' : '编辑')
          .fontSize(13)
          .fontColor('#00A86B')
          .onClick(() => {
            this.prefExpanded = !this.prefExpanded;
          })
      }
      .width('100%')

      Row() {
        Text('健康目标：' + this.goalSummary())
          .fontSize(13)
          .fontColor('#999999')
        Text(this.tasteSel.length > 0 ? ' · 口味 ' + this.tasteSel.length + ' 项' : '')
          .fontSize(13)
          .fontColor('#999999')
        Text(this.cuisineSel.length > 0 ? ' · 菜系 ' + this.cuisineSel.length + ' 项' : '')
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ top: 6 })

      if (this.prefExpanded) {
        Column() {
          this.groupLabel('健康目标')
          Row({ space: 10 }) {
            ForEach(GOAL_CODES, (code: string) => {
              this.goalChip(code)
            }, (code: string) => code)
          }
          .width('100%')
          .margin({ top: 8 })

          this.groupLabel('口味偏好')
          Row({ space: 10 }) {
            ForEach(TASTE_OPTIONS, (name: string) => {
              this.tasteChip(name)
            }, (name: string) => name)
          }
          .width('100%')
          .margin({ top: 8 })

          this.groupLabel('菜系偏好')
          Row({ space: 10 }) {
            ForEach(CUISINE_OPTIONS, (name: string) => {
              this.cuisineChip(name)
            }, (name: string) => name)
          }
          .width('100%')
          .margin({ top: 8 })

          this.groupLabel('预算区间（元）')
          Row({ space: 10 }) {
            TextInput({ placeholder: '最低价', text: this.budgetMinText })
              .layoutWeight(1)
              .height(40)
              .fontSize(14)
              .backgroundColor('#F5F6F7')
              .borderRadius(8)
              .padding({ left: 10, right: 10 })
              .onChange((value: string) => {
                this.budgetMinText = value;
              })
            Text('-')
              .fontSize(14)
              .fontColor('#999999')
            TextInput({ placeholder: '最高价', text: this.budgetMaxText })
              .layoutWeight(1)
              .height(40)
              .fontSize(14)
              .backgroundColor('#F5F6F7')
              .borderRadius(8)
              .padding({ left: 10, right: 10 })
              .onChange((value: string) => {
                this.budgetMaxText = value;
              })
          }
          .width('100%')
          .margin({ top: 8 })

          Button(this.savingPref ? '保存中...' : '保存偏好')
            .width('100%')
            .height(40)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#00A86B')
            .borderRadius(20)
            .margin({ top: 16 })
            .onClick(() => {
              this.savePreference();
            })
        }
        .width('100%')
      }
    }
    .width('92%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 12 })
  }

  @Builder
  avoidCard() {
    Column() {
      Text('我的忌口')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .width('100%')

      if (this.avoidList.length === 0) {
        Text('暂无记录，添加忌口后推荐将自动避开相关菜品')
          .fontSize(12)
          .fontColor('#999999')
          .width('100%')
          .margin({ top: 8 })
      } else {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.avoidList, (v: AvoidVo) => {
            Column() {
              this.avoidChip(v)
            }
            .margin({ right: 10, top: 10 })
          }, (v: AvoidVo) => v.id)
        }
        .width('100%')
      }

      Text('快捷添加')
        .fontSize(12)
        .fontColor('#999999')
        .width('100%')
        .margin({ top: 14 })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(QUICK_AVOIDS, (name: string) => {
          Column() {
            this.quickAvoidChip(name)
          }
          .margin({ right: 10, top: 8 })
        }, (name: string) => name)
      }
      .width('100%')

      Row({ space: 8 }) {
        TextInput({ placeholder: '自定义忌口项，如：鸡蛋', text: this.avoidInput })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#F5F6F7')
          .borderRadius(8)
          .padding({ left: 10, right: 10 })
          .onChange((value: string) => {
            this.avoidInput = value;
          })
        Button('添加')
          .height(40)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#00A86B')
          .borderRadius(8)
          .onClick(() => {
            this.addAvoid(this.avoidInput);
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('92%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 12 })
  }

  @Builder
  healthAuthCard() {
    Column() {
      Row() {
        Text('健康数据授权')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
        Blank()
        Text(this.authStatus === 1 ? '已授权' : '未授权')
          .fontSize(12)
          .fontColor(this.authStatus === 1 ? '#00A86B' : '#999999')
      }
      .width('100%')

      Text('授权华为运动健康后，可同步手表步数、睡眠、心率等数据，获得更精准的饮食推荐')
        .fontSize(12)
        .fontColor('#999999')
        .width('100%')
        .margin({ top: 8 })

      if (this.authStatus === 1) {
        Button(this.authorizing ? '处理中...' : '取消授权')
          .width('100%')
          .height(40)
          .fontSize(14)
          .fontColor('#E5484D')
          .backgroundColor('#FFF0F0')
          .borderRadius(20)
          .margin({ top: 14 })
          .enabled(!this.authorizing)
          .onClick(() => {
            this.confirmRevoke();
          })
      } else {
        Button(this.authorizing ? '授权中...' : '授权华为运动健康')
          .width('100%')
          .height(40)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#00A86B')
          .borderRadius(20)
          .margin({ top: 14 })
          .enabled(!this.authorizing)
          .onClick(() => {
            this.confirmAuthorize();
          })
      }
    }
    .width('92%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 12 })
  }

  @Builder
  aboutCard() {
    Column() {
      Row() {
        Text('关于膳衡')
          .fontSize(15)
          .fontColor('#1A1A1A')
        Blank()
        Text('v1.0.0')
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')
      .height(50)
      .onClick(() => {
        this.enterAbout();
      })
    }
    .width('92%')
    .padding({ left: 18, right: 18 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .margin({ top: 14 })
  }

  build() {
    Column() {
      Row() {
        Text('我的')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 8 })

      Scroll() {
        Column() {
          this.userCard()
          this.menuCard()
          this.preferenceCard()
          this.avoidCard()
          this.healthAuthCard()
          this.aboutCard()
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}