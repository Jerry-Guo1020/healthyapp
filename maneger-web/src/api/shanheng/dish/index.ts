import request from '@/utils/request';
import { AxiosPromise } from 'axios';

/** 菜品查询参数 */
export interface DishQuery {
  pageNum: number;
  pageSize: number;
  name?: string;
  categoryId?: number;
  status?: number;
}

/** 菜品视图对象 */
export interface DishVO {
  id: number;
  name: string;
  categoryId: number;
  categoryName?: string;
  description?: string;
  coverUrl?: string;
  ingredients?: string;
  calorie?: number;
  spicyLevel?: number;
  oilLevel?: number;
  isLight?: number;
  isWarm?: number;
  isEasyDigest?: number;
  priceMin?: number;
  priceMax?: number;
  protein?: number;
  fat?: number;
  carbs?: number;
  status?: number;
  favoriteCount?: number;
  viewCount?: number;
  createTime?: string;
}

/** 菜品表单 */
export interface DishForm {
  id?: number;
  name: string;
  categoryId?: number;
  description?: string;
  coverUrl?: string;
  ingredients?: string;
  calorie?: number;
  spicyLevel?: number;
  oilLevel?: number;
  isLight?: number;
  isWarm?: number;
  isEasyDigest?: number;
  priceMin?: number;
  priceMax?: number;
  protein?: number;
  fat?: number;
  carbs?: number;
  status?: number;
}

/** 分页查询菜品列表 */
export function listDish(query: DishQuery): AxiosPromise<{ total: number; rows: DishVO[] }> {
  return request({
    url: '/shanheng/dish/list',
    method: 'get',
    params: query
  });
}

/** 查询菜品详情 */
export function getDish(id: number): AxiosPromise<{ code: number; msg: string; data: DishVO }> {
  return request({
    url: '/shanheng/dish/' + id,
    method: 'get'
  });
}

/** 新增菜品 */
export function addDish(data: DishForm) {
  return request({
    url: '/shanheng/dish',
    method: 'post',
    data
  });
}

/** 修改菜品 */
export function updateDish(data: DishForm) {
  return request({
    url: '/shanheng/dish',
    method: 'put',
    data
  });
}

/** 删除菜品（支持单个/批量） */
export function delDish(id: number | number[]) {
  return request({
    url: '/shanheng/dish/' + id,
    method: 'delete'
  });
}

/** 联网补全营养（USDA） */
export function enrichDish(id: number, keyword?: string): AxiosPromise<{ code: number; msg: string; data: DishVO }> {
  return request({
    url: '/shanheng/dish/enrich/' + id,
    method: 'post',
    data: { keyword }
  });
}