<script setup>
import { ref, computed, onMounted, inject } from 'vue'
import { useRouter } from 'vue-router'
import { getCategories, getGoods, getSeckillGoods } from '../services/goods'

const notify = inject('notify')
const router = useRouter()

// ---- 登录态（登录成功后由 LoginCard 写入 sessionStorage） ----
const user = ref(null)
try {
  const raw = sessionStorage.getItem('starshop_user')
  if (raw) user.value = JSON.parse(raw)
} catch (e) {
  user.value = null
}

const categories = ref([]) // 分类树
const goods = ref([]) // 商品列表
const seckill = ref([]) // 秒杀商品
const keyword = ref('')
const activeTop = ref(null) // 当前选中的顶级分类 id，null = 全部
const activeSub = ref(null) // 当前选中的二级分类 id
const loading = ref(false)

/** 当前选中的顶级分类对象（用于渲染二级分类行） */
const topCategory = computed(
  () => categories.value.find((c) => c.id === activeTop.value) || null
)
/** 实际传给后端的分类ID：优先二级，其次顶级，都没有则全部 */
const queryCategoryId = computed(() => activeSub.value ?? activeTop.value)

function price(v) {
  return v === null || v === undefined ? '--' : Number(v).toFixed(2)
}

async function loadCategories() {
  const res = await getCategories()
  if (res.ok) categories.value = res.data
  else notify(res.msg)
}

async function loadGoods() {
  loading.value = true
  const res = await getGoods({ keyword: keyword.value.trim(), categoryId: queryCategoryId.value })
  loading.value = false
  if (res.ok) {
    goods.value = res.data
    if (!res.data.length) notify('这片星域暂无商品')
  } else {
    goods.value = []
    notify(res.msg)
  }
}

async function loadSeckill() {
  const res = await getSeckillGoods()
  if (res.ok) seckill.value = res.data
}

/** 点击顶级分类：切换选中，并清空二级选择 */
function pickTop(id) {
  activeTop.value = activeTop.value === id ? null : id
  activeSub.value = null
  loadGoods()
}

/** 点击二级分类 */
function pickSub(id) {
  activeSub.value = activeSub.value === id ? null : id
  loadGoods()
}

function onSearch() {
  loadGoods()
}

function resetFilter() {
  keyword.value = ''
  activeTop.value = null
  activeSub.value = null
  loadGoods()
}

function logout() {
  sessionStorage.removeItem('starshop_user')
  user.value = null
  notify('已退出登录，期待下次星辰相逢 ✦')
  router.push('/login')
}

onMounted(async () => {
  await loadCategories()
  loadGoods()
  loadSeckill()
})
</script>

<template>
  <div class="home">
    <!-- 顶部导航 -->
    <header class="topbar">
      <div class="brand">
        <span class="logo-ic">✦</span>
        <span class="brand-text">星购商城</span>
      </div>

      <div class="search">
        <input
          v-model="keyword"
          type="text"
          placeholder="搜索星辰好物…"
          @keyup.enter="onSearch"
        />
        <button type="button" @click="onSearch">搜索</button>
      </div>

      <div class="user-box">
        <span class="avatar">{{ (user?.username || user?.account || '?').slice(0, 1) }}</span>
        <span class="uname">{{ user?.username || user?.account || '游客' }}</span>
        <button type="button" class="logout" @click="logout">退出</button>
      </div>
    </header>

    <!-- 分类筛选 -->
    <nav class="cats">
      <button class="chip" :class="{ on: activeTop === null }" @click="resetFilter">全部</button>
      <button
        v-for="c in categories"
        :key="c.id"
        class="chip"
        :class="{ on: activeTop === c.id }"
        @click="pickTop(c.id)"
      >
        {{ c.name }}
      </button>
    </nav>

    <nav v-if="topCategory && topCategory.children && topCategory.children.length" class="cats sub">
      <button
        v-for="s in topCategory.children"
        :key="s.id"
        class="chip small"
        :class="{ on: activeSub === s.id }"
        @click="pickSub(s.id)"
      >
        {{ s.name }}
      </button>
    </nav>

    <!-- 秒杀专区 -->
    <section v-if="seckill.length" class="block">
      <h2 class="block-title">⚡ 星辰秒杀</h2>
      <div class="seckill-row">
        <div v-for="p in seckill" :key="p.id" class="sk-card">
          <div class="sk-icon">{{ p.icon || '✦' }}</div>
          <div class="sk-body">
            <div class="sk-name">{{ p.name }}</div>
            <div class="sk-price">
              <span class="now">¥{{ price(p.seckillPrice) }}</span>
              <span class="old">¥{{ price(p.price) }}</span>
            </div>
          </div>
          <div class="sk-stock">仅剩 {{ p.seckillStock }} 件</div>
        </div>
      </div>
    </section>

    <!-- 商品列表 -->
    <section class="block">
      <h2 class="block-title">
        ✦ 商品星域
        <span class="count">{{ loading ? '加载中…' : `共 ${goods.length} 件` }}</span>
      </h2>

      <div v-if="!goods.length && !loading" class="empty">没有找到符合条件的商品</div>

      <div v-else class="grid">
        <article v-for="p in goods" :key="p.id" class="card">
          <div class="thumb">{{ p.icon || '✦' }}</div>
          <div class="name">{{ p.name }}</div>
          <div class="desc">{{ p.description }}</div>
          <div class="meta">
            <span class="price">¥{{ price(p.price) }}</span>
            <span v-if="p.originalPrice" class="origin">¥{{ price(p.originalPrice) }}</span>
          </div>
          <div class="foot">
            <span class="tag">{{ p.categoryName || '未分类' }}</span>
            <span class="sales">已售 {{ p.sales }}</span>
          </div>
          <span v-if="p.isHot === 1" class="badge hot">热销</span>
          <span v-else-if="p.isSeckill === 1" class="badge seckill">秒杀</span>
        </article>
      </div>
    </section>
  </div>
</template>

<style scoped>
.home {
  width: min(1180px, 94vw);
  margin: 0 auto;
  padding: 26px 0 60px;
}

/* ---------- 顶部导航 ---------- */
.topbar {
  display: flex;
  align-items: center;
  gap: 22px;
  padding: 16px 22px;
  border-radius: 20px;
  background: linear-gradient(160deg, rgba(30, 35, 80, 0.55), rgba(18, 21, 52, 0.45));
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(148, 170, 255, 0.22);
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.45);
}
.brand {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
}
.logo-ic {
  width: 38px;
  height: 38px;
  display: grid;
  place-items: center;
  border-radius: 12px;
  font-size: 20px;
  background: linear-gradient(135deg, #6ee7f9, #8b5cf6 55%, #ec4899);
  box-shadow: 0 6px 18px rgba(139, 92, 246, 0.45);
}
.brand-text {
  font-size: 21px;
  font-weight: 700;
  letter-spacing: 3px;
  background: linear-gradient(92deg, var(--cyan), var(--violet) 45%, var(--pink));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  font-family: "STKaiti", "KaiTi", serif;
}

.search {
  flex: 1;
  display: flex;
  gap: 8px;
}
.search input {
  flex: 1;
  padding: 10px 16px;
  font-size: 14px;
  color: #f1f5ff;
  background: rgba(13, 17, 44, 0.55);
  border: 1px solid rgba(140, 160, 255, 0.22);
  border-radius: 12px;
  outline: none;
  font-family: inherit;
  transition: all 0.3s;
}
.search input:focus {
  border-color: rgba(167, 139, 250, 0.8);
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.18);
}
.search button {
  padding: 10px 20px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  color: #fffdf5;
  font-size: 14px;
  font-family: inherit;
  background: linear-gradient(92deg, #38bdf8, #8b5cf6 55%, #ec4899);
  box-shadow: 0 8px 22px rgba(139, 92, 246, 0.35);
}
.search button:hover {
  filter: brightness(1.12);
}

.user-box {
  display: flex;
  align-items: center;
  gap: 9px;
  flex-shrink: 0;
}
.avatar {
  width: 32px;
  height: 32px;
  display: grid;
  place-items: center;
  border-radius: 50%;
  font-size: 15px;
  color: #0b1029;
  background: linear-gradient(135deg, var(--cyan), var(--violet));
}
.uname {
  font-size: 13.5px;
  color: #cbd5f5;
  max-width: 110px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.logout {
  padding: 6px 14px;
  font-size: 12.5px;
  cursor: pointer;
  color: #cbd5f5;
  background: rgba(13, 17, 44, 0.6);
  border: 1px solid rgba(148, 170, 255, 0.28);
  border-radius: 10px;
  font-family: inherit;
}
.logout:hover {
  color: var(--pink);
  border-color: var(--pink);
}

/* ---------- 分类 ---------- */
.cats {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin: 22px 0 0;
}
.cats.sub {
  margin-top: 10px;
}
.chip {
  padding: 8px 18px;
  font-size: 13.5px;
  cursor: pointer;
  color: #c7d2fe;
  background: rgba(20, 24, 58, 0.55);
  border: 1px solid rgba(148, 170, 255, 0.24);
  border-radius: 999px;
  font-family: inherit;
  transition: all 0.25s;
}
.chip:hover {
  color: #fff;
  border-color: var(--violet);
  transform: translateY(-2px);
}
.chip.on {
  color: #0b1029;
  font-weight: 600;
  border-color: transparent;
  background: linear-gradient(92deg, var(--cyan), var(--violet));
  box-shadow: 0 6px 18px rgba(139, 92, 246, 0.4);
}
.chip.small {
  padding: 6px 14px;
  font-size: 12.5px;
}

/* ---------- 区块 ---------- */
.block {
  margin-top: 30px;
}
.block-title {
  font-size: 17px;
  font-weight: 600;
  letter-spacing: 2px;
  margin-bottom: 16px;
  background: linear-gradient(92deg, var(--cyan), var(--violet) 50%, var(--pink));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}
.count {
  margin-left: 10px;
  font-size: 12.5px;
  font-weight: 400;
  letter-spacing: 1px;
  color: rgba(176, 188, 235, 0.7);
  -webkit-text-fill-color: rgba(176, 188, 235, 0.7);
}

/* ---------- 秒杀 ---------- */
.seckill-row {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 14px;
}
.sk-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 16px;
  border-radius: 16px;
  background: linear-gradient(135deg, rgba(236, 72, 153, 0.16), rgba(139, 92, 246, 0.12));
  border: 1px solid rgba(249, 168, 212, 0.28);
}
.sk-icon {
  font-size: 30px;
}
.sk-body {
  flex: 1;
  min-width: 0;
}
.sk-name {
  font-size: 14px;
  color: #f1f5ff;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.sk-price {
  margin-top: 6px;
  display: flex;
  align-items: baseline;
  gap: 8px;
}
.sk-price .now {
  font-size: 18px;
  font-weight: 700;
  color: #fb7185;
}
.sk-price .old {
  font-size: 12.5px;
  color: rgba(203, 213, 245, 0.55);
  text-decoration: line-through;
}
.sk-stock {
  font-size: 12px;
  color: var(--gold);
  flex-shrink: 0;
}

/* ---------- 商品网格 ---------- */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
  gap: 16px;
}
.card {
  position: relative;
  padding: 18px 16px 14px;
  border-radius: 18px;
  text-align: center;
  background: linear-gradient(160deg, rgba(30, 35, 80, 0.5), rgba(18, 21, 52, 0.4));
  border: 1px solid rgba(148, 170, 255, 0.18);
  transition: all 0.3s;
}
.card:hover {
  transform: translateY(-5px);
  border-color: rgba(167, 139, 250, 0.6);
  box-shadow: 0 16px 36px rgba(0, 0, 0, 0.45), 0 0 26px rgba(139, 92, 246, 0.22);
}
.thumb {
  font-size: 42px;
  line-height: 1.2;
}
.name {
  margin-top: 8px;
  font-size: 14.5px;
  color: #eef2ff;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.desc {
  margin-top: 5px;
  font-size: 12px;
  color: rgba(178, 190, 230, 0.62);
  height: 32px;
  overflow: hidden;
}
.meta {
  margin-top: 10px;
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 8px;
}
.price {
  font-size: 18px;
  font-weight: 700;
  color: var(--gold);
}
.origin {
  font-size: 12px;
  color: rgba(203, 213, 245, 0.5);
  text-decoration: line-through;
}
.foot {
  margin-top: 10px;
  display: flex;
  justify-content: space-between;
  font-size: 11.5px;
  color: rgba(178, 190, 230, 0.6);
}
.tag {
  padding: 2px 8px;
  border-radius: 999px;
  background: rgba(139, 92, 246, 0.18);
  color: #c4b5fd;
}
.badge {
  position: absolute;
  top: 10px;
  right: 10px;
  padding: 2px 9px;
  font-size: 11px;
  border-radius: 999px;
  color: #fff;
}
.badge.hot {
  background: linear-gradient(92deg, #f97316, #ec4899);
}
.badge.seckill {
  background: linear-gradient(92deg, #ef4444, #f59e0b);
}

.empty {
  padding: 50px 0;
  text-align: center;
  font-size: 14px;
  color: rgba(178, 190, 230, 0.6);
}

@media (max-width: 720px) {
  .topbar {
    flex-wrap: wrap;
  }
  .search {
    order: 3;
    flex-basis: 100%;
  }
}
</style>
