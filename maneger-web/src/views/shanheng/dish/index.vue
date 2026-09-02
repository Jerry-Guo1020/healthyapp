<template>
  <div class="p-2">
    <!-- 搜索区 -->
    <transition :enter-active-class="proxy?.animate.searchAnimate.enter" :leave-active-class="proxy?.animate.searchAnimate.leave">
      <div v-show="showSearch" class="mb-[10px]">
        <el-card shadow="never">
          <el-form ref="queryFormRef" :model="queryParams" :inline="true">
            <el-form-item label="菜品名称" prop="name">
              <el-input v-model="queryParams.name" placeholder="请输入菜品名称" clearable @keyup.enter="handleQuery" />
            </el-form-item>
            <el-form-item label="分类" prop="categoryId">
              <el-select v-model="queryParams.categoryId" placeholder="请选择分类" clearable style="width: 160px">
                <el-option v-for="c in categoryOptions" :key="c.value" :label="c.label" :value="c.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="状态" prop="status">
              <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 140px">
                <el-option label="草稿" :value="0" />
                <el-option label="上架" :value="1" />
                <el-option label="下架" :value="2" />
                <el-option label="待审核" :value="3" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
              <el-button icon="Refresh" @click="resetQuery">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </div>
    </transition>

    <el-card shadow="never">
      <template #header>
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button v-hasPermi="['shanheng:dish:add']" type="primary" plain icon="Plus" @click="handleAdd">新增</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button v-hasPermi="['shanheng:dish:import']" type="warning" plain icon="Upload" @click="handleImport">导入</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button v-hasPermi="['shanheng:dish:import']" type="primary" plain icon="Download" @click="handleImportTemplate">下载模板</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button v-hasPermi="['shanheng:dish:edit']" type="success" plain icon="Edit" :disabled="single" @click="handleUpdate()">修改</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button v-hasPermi="['shanheng:dish:remove']" type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete()">删除</el-button>
          </el-col>
          <right-toolbar v-model:show-search="showSearch" @query-table="getList"></right-toolbar>
        </el-row>
      </template>

      <el-table v-loading="loading" border :data="dishList" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="ID" align="center" prop="id" width="70" />
        <el-table-column label="菜品名称" align="center" prop="name" min-width="140" show-overflow-tooltip />
        <el-table-column label="分类" align="center" prop="categoryName" width="110" />
        <el-table-column label="热量(kcal)" align="center" prop="calorie" width="100" />
        <el-table-column label="蛋白(g)" align="center" prop="protein" width="90">
          <template #default="scope">{{ scope.row.protein ?? '-' }}</template>
        </el-table-column>
        <el-table-column label="脂肪(g)" align="center" prop="fat" width="90">
          <template #default="scope">{{ scope.row.fat ?? '-' }}</template>
        </el-table-column>
        <el-table-column label="碳水(g)" align="center" prop="carbs" width="90">
          <template #default="scope">{{ scope.row.carbs ?? '-' }}</template>
        </el-table-column>
        <el-table-column label="状态" align="center" prop="status" width="90">
          <template #default="scope">
            <el-tag :type="statusTag(scope.row.status).type">{{ statusTag(scope.row.status).label }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" align="center" prop="createTime" width="180">
          <template #default="scope">
            <span>{{ proxy?.parseTime(scope.row.createTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center" class-name="small-padding fixed-width">
          <template #default="scope">
            <el-tooltip content="修改" placement="top">
              <el-button v-hasPermi="['shanheng:dish:edit']" link type="primary" icon="Edit" @click="handleUpdate(scope.row)"></el-button>
            </el-tooltip>
            <el-tooltip content="联网补全营养" placement="top">
              <el-button v-hasPermi="['shanheng:dish:edit']" link type="success" icon="MagicStick" @click="handleEnrich(scope.row)"></el-button>
            </el-tooltip>
            <el-tooltip content="删除" placement="top">
              <el-button v-hasPermi="['shanheng:dish:remove']" link type="danger" icon="Delete" @click="handleDelete(scope.row)"></el-button>
            </el-tooltip>
          </template>
        </el-table-column>
      </el-table>

      <pagination
        v-show="total > 0"
        v-model:page="queryParams.pageNum"
        v-model:limit="queryParams.pageSize"
        :total="total"
        @pagination="getList"
      />
    </el-card>

    <!-- 新增 / 修改对话框 -->
    <el-dialog v-model="dialog.visible" :title="dialog.title" width="680px" append-to-body>
      <el-form ref="dishFormRef" :model="form" :rules="rules" label-width="90px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="菜品名称" prop="name">
              <el-input v-model="form.name" placeholder="请输入菜品名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="主分类" prop="categoryId">
              <el-select v-model="form.categoryId" placeholder="请选择分类" style="width: 100%">
                <el-option v-for="c in categoryOptions" :key="c.value" :label="c.label" :value="c.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="封面URL" prop="coverUrl">
              <el-input v-model="form.coverUrl" placeholder="R2 图片 URL" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="食材" prop="ingredients">
              <el-input v-model="form.ingredients" type="textarea" :rows="2" placeholder='JSON 数组，如 ["鸡胸肉","西兰花"]' />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="描述" prop="description">
              <el-input v-model="form.description" type="textarea" :rows="2" placeholder="请输入菜品描述" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="热量" prop="calorie">
              <el-input-number v-model="form.calorie" :min="0" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="辣度" prop="spicyLevel">
              <el-input-number v-model="form.spicyLevel" :min="0" :max="3" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="油度" prop="oilLevel">
              <el-input-number v-model="form.oilLevel" :min="0" :max="3" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="清淡" prop="isLight">
              <el-switch v-model="form.isLight" :active-value="1" :inactive-value="0" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="暖胃" prop="isWarm">
              <el-switch v-model="form.isWarm" :active-value="1" :inactive-value="0" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="易消化" prop="isEasyDigest">
              <el-switch v-model="form.isEasyDigest" :active-value="1" :inactive-value="0" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="价格下限" prop="priceMin">
              <el-input-number v-model="form.priceMin" :min="0" :precision="2" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="价格上限" prop="priceMax">
              <el-input-number v-model="form.priceMax" :min="0" :precision="2" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="蛋白质(g)" prop="protein">
              <el-input-number v-model="form.protein" :min="0" :precision="2" :step="0.1" controls-position="right" style="width: 100%" placeholder="留空未录入" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="脂肪(g)" prop="fat">
              <el-input-number v-model="form.fat" :min="0" :precision="2" :step="0.1" controls-position="right" style="width: 100%" placeholder="留空未录入" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="碳水(g)" prop="carbs">
              <el-input-number v-model="form.carbs" :min="0" :precision="2" :step="0.1" controls-position="right" style="width: 100%" placeholder="留空未录入" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="form.status" style="width: 100%">
                <el-option label="草稿" :value="0" />
                <el-option label="上架" :value="1" />
                <el-option label="下架" :value="2" />
                <el-option label="待审核" :value="3" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 联网补全对话框 -->
    <el-dialog v-model="enrichDialog.visible" title="联网补全营养（USDA）" width="460px" append-to-body>
      <el-alert type="info" :closable="false" class="mb-3" show-icon
        title="通过 USDA FoodData Central 回填菜品每100g的蛋白质/脂肪/碳水。留空英文关键词将由菜品名/食材自动推导。" />
      <el-form label-width="110px">
        <el-form-item label="菜品">
          <el-input v-model="enrichDialog.dishName" disabled />
        </el-form-item>
        <el-form-item label="英文关键词">
          <el-input v-model="enrichDialog.keyword" placeholder="如 chicken breast（留空自动推导）" clearable />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" :loading="enrichDialog.loading" @click="submitEnrich">开始补全</el-button>
          <el-button @click="enrichDialog.visible = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 导入对话框 -->
    <el-dialog v-model="upload.open" title="导入菜品" width="460px" append-to-body>
      <el-upload
        ref="uploadRef"
        :limit="1"
        accept=".xlsx, .xls"
        :disabled="upload.isUploading"
        :on-change="handleFileChange"
        :on-remove="handleFileRemove"
        :auto-upload="false"
        drag
      >
        <el-icon class="el-icon--upload">
          <i-ep-upload-filled />
        </el-icon>
        <div class="el-upload__text">将文件拖到此处，或<em>点击选取文件</em></div>
        <template #tip>
          <div class="text-center el-upload__tip">
            <span>仅允许导入 xls、xlsx 格式文件，菜品名称与分类名称为必填。</span>
            <div>
              <el-link type="primary" :underline="false" style="font-size: 12px" @click="handleImportTemplate">下载模板</el-link>
            </div>
          </div>
        </template>
      </el-upload>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" :loading="upload.isUploading" @click="submitImport">确 定</el-button>
          <el-button @click="upload.open = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="ShDish" lang="ts">
import { listDish, getDish, addDish, updateDish, delDish, enrichDish, importDishData, importDishTemplate } from '@/api/shanheng/dish';
import type { DishForm, DishQuery, DishVO } from '@/api/shanheng/dish';

const { proxy } = getCurrentInstance() as ComponentInternalInstance;

/** 分类下拉（占位：对应种子数据 8 分类；后续建「分类管理」后改为接口加载） */
const categoryOptions = [
  { value: 1, label: '早餐' },
  { value: 2, label: '午餐' },
  { value: 3, label: '晚餐' },
  { value: 4, label: '粤菜' },
  { value: 5, label: '川菜' },
  { value: 6, label: '轻食沙拉' },
  { value: 7, label: '低卡减脂' },
  { value: 8, label: '养胃暖食' }
];

const dishList = ref<DishVO[]>([]);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref<number[]>([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);
const dishFormRef = ref<ElFormInstance>();
const queryFormRef = ref<ElFormInstance>();

const dialog = reactive<DialogOption>({
  visible: false,
  title: ''
});

const enrichDialog = reactive({
  visible: false,
  loading: false,
  dishName: '',
  dishId: 0,
  keyword: ''
});

const upload = reactive({
  open: false,
  isUploading: false
});
const importFile = ref<File>();
const uploadRef = ref<ElUploadInstance>();

const initFormData: DishForm = {
  id: undefined,
  name: '',
  categoryId: undefined,
  description: '',
  coverUrl: '',
  ingredients: '[]',
  calorie: 0,
  spicyLevel: 0,
  oilLevel: 0,
  isLight: 0,
  isWarm: 0,
  isEasyDigest: 0,
  priceMin: 0,
  priceMax: 0,
  protein: undefined,
  fat: undefined,
  carbs: undefined,
  status: 1
};

const data = reactive<PageData<DishForm, DishQuery>>({
  form: { ...initFormData },
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    name: '',
    categoryId: undefined,
    status: undefined
  },
  rules: {
    name: [{ required: true, message: '菜品名称不能为空', trigger: 'blur' }],
    categoryId: [{ required: true, message: '主分类不能为空', trigger: 'change' }]
  }
});

const { queryParams, form, rules } = toRefs<PageData<DishForm, DishQuery>>(data);

/** 状态标签映射 */
const statusTag = (status?: number) => {
  switch (status) {
    case 1:
      return { type: 'success' as const, label: '上架' };
    case 2:
      return { type: 'danger' as const, label: '下架' };
    case 3:
      return { type: 'warning' as const, label: '待审核' };
    default:
      return { type: 'info' as const, label: '草稿' };
  }
};

/** 查询列表 */
const getList = async () => {
  loading.value = true;
  const res = await listDish(queryParams.value);
  dishList.value = res.rows;
  total.value = res.total;
  loading.value = false;
};

/** 取消按钮 */
const cancel = () => {
  reset();
  dialog.visible = false;
};

/** 表单重置 */
const reset = () => {
  form.value = { ...initFormData };
  dishFormRef.value?.resetFields();
};

/** 搜索 */
const handleQuery = () => {
  queryParams.value.pageNum = 1;
  getList();
};

/** 重置搜索 */
const resetQuery = () => {
  queryFormRef.value?.resetFields();
  queryParams.value.pageNum = 1;
  queryParams.value.categoryId = undefined;
  queryParams.value.status = undefined;
  handleQuery();
};

/** 多选 */
const handleSelectionChange = (selection: DishVO[]) => {
  ids.value = selection.map((item) => item.id);
  single.value = selection.length != 1;
  multiple.value = !selection.length;
};

/** 新增 */
const handleAdd = () => {
  reset();
  dialog.visible = true;
  dialog.title = '添加菜品';
};

/** 修改 */
const handleUpdate = async (row?: DishVO) => {
  reset();
  const id = row?.id || ids.value[0];
  const res = await getDish(id);
  Object.assign(form.value, res.data);
  dialog.visible = true;
  dialog.title = '修改菜品';
};

/** 提交 */
const submitForm = () => {
  dishFormRef.value?.validate(async (valid: boolean) => {
    if (valid) {
      form.value.id ? await updateDish(form.value) : await addDish(form.value);
      proxy?.$modal.msgSuccess('操作成功');
      dialog.visible = false;
      await getList();
    }
  });
};

/** 删除 */
const handleDelete = async (row?: DishVO) => {
  const ids2 = row?.id ? [row.id] : ids.value;
  await proxy?.$modal.confirm('是否确认删除所选菜品数据？');
  await delDish(ids2);
  await getList();
  proxy?.$modal.msgSuccess('删除成功');
};

/** 打开联网补全 */
const handleEnrich = (row: DishVO) => {
  enrichDialog.dishId = row.id;
  enrichDialog.dishName = row.name;
  enrichDialog.keyword = '';
  enrichDialog.visible = true;
};

/** 提交联网补全 */
const submitEnrich = async () => {
  enrichDialog.loading = true;
  try {
    const keyword = enrichDialog.keyword?.trim() || undefined;
    const res = await enrichDish(enrichDialog.dishId, keyword);
    proxy?.$modal.msgSuccess(
      `补全成功：蛋白 ${res.data.protein ?? 0}g · 脂肪 ${res.data.fat ?? 0}g · 碳水 ${res.data.carbs ?? 0}g（每100g）`
    );
    enrichDialog.visible = false;
    await getList();
  } finally {
    enrichDialog.loading = false;
  }
};

/** 打开导入 */
const handleImport = () => {
  upload.open = true;
};

/** 下载导入模板 */
const handleImportTemplate = () => {
  importDishTemplate();
};

/** 选择文件 */
const handleFileChange = (file: UploadFile) => {
  importFile.value = file.raw;
};

/** 移除文件 */
const handleFileRemove = () => {
  importFile.value = undefined;
};

/** 提交导入 */
const submitImport = async () => {
  if (!importFile.value) {
    proxy?.$modal.msgWarning('请先选择要导入的 xlsx 文件');
    return;
  }
  upload.isUploading = true;
  try {
    const formData = new FormData();
    formData.append('file', importFile.value);
    await importDishData(formData);
    proxy?.$modal.msgSuccess('导入成功');
    upload.open = false;
    importFile.value = undefined;
    uploadRef.value?.clearFiles();
    await getList();
  } finally {
    upload.isUploading = false;
  }
};

onMounted(() => {
  getList();
});
</script>