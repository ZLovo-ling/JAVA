// 商品 / 分类接口：同样经 Vite 代理转发到 Spring Boot（8081）
// 统一返回结构 ApiResult：{ code:200 成功 / 其他 失败, message, data }

const API = '/api'

async function getJson(url) {
  const res = await fetch(url, { headers: { Accept: 'application/json' } })
  let data = null
  try {
    data = await res.json()
  } catch (e) {
    data = null
  }
  if (data && data.code === 200) {
    return { ok: true, msg: data.message || 'success', data: data.data || [] }
  }
  return { ok: false, msg: (data && data.message) || `请求失败(${res.status})`, data: [] }
}

/** 分类树（顶级 -> 二级） */
export function getCategories() {
  return getJson(`${API}/categories`)
}

/**
 * 商品列表 / 搜索
 * @param {string} keyword    关键词（可空）
 * @param {number|null} categoryId 分类ID（可空表示全部；传顶级分类会自动包含后代）
 */
export function getGoods({ keyword = '', categoryId = null } = {}) {
  const q = new URLSearchParams()
  if (keyword) q.set('keyword', keyword)
  if (categoryId !== null && categoryId !== undefined && categoryId !== '') {
    q.set('categoryId', String(categoryId))
  }
  const qs = q.toString()
  return getJson(`${API}/goods${qs ? `?${qs}` : ''}`)
}

/** 秒杀商品列表 */
export function getSeckillGoods() {
  return getJson(`${API}/goods/seckill`)
}
