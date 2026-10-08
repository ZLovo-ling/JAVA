<script setup>
import { ref, onMounted, onUnmounted, provide } from 'vue'
import Starfield from './components/Starfield.vue'
import Moon from './components/Moon.vue'

const toastShow = ref(false)
const toastMsg = ref('')
let toastTimer = null

function notify(msg) {
  toastMsg.value = msg
  toastShow.value = true
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => {
    toastShow.value = false
  }, 2600)
}
// 供所有页面/组件调用全局提示
provide('notify', notify)

const showBackTop = ref(false)
function onScroll() {
  showBackTop.value = window.scrollY > 220
}
function toTop() {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

onMounted(() => window.addEventListener('scroll', onScroll))
onUnmounted(() => window.removeEventListener('scroll', onScroll))
</script>

<template>
  <!-- 动态星空背景层 -->
  <div class="sky"></div>
  <div class="galaxy"></div>
  <div class="nebula"></div>
  <div class="nebula b"></div>
  <Starfield />
  <Moon />

  <!-- 主容器（路由出口） -->
  <div class="wrap">
    <router-view />
  </div>

  <!-- 提示 toast -->
  <div class="toast" :class="{ show: toastShow }">✦ {{ toastMsg }}</div>

  <!-- 返回顶部 -->
  <button class="back-top" :class="{ show: showBackTop }" @click="toTop" title="回到星空之巅">✦</button>
</template>

<style scoped>
/* ---------- 夜空底层背景 ---------- */
.sky {
  position: fixed;
  inset: 0;
  z-index: 0;
  background:
    radial-gradient(1200px 700px at 80% -10%, rgba(120, 100, 255, 0.28), transparent 60%),
    radial-gradient(900px 600px at 10% 105%, rgba(56, 189, 248, 0.18), transparent 60%),
    radial-gradient(700px 500px at 50% 50%, rgba(232, 121, 249, 0.1), transparent 65%),
    linear-gradient(180deg, #0b1029 0%, #151b43 42%, #241b50 68%, #0c0f2c 100%);
}

/* 缓慢旋转的银河光带 —— 让远景持续流动 */
.galaxy {
  position: fixed;
  z-index: 0;
  top: 50%;
  left: 50%;
  width: 220vmax;
  height: 220vmax;
  margin: -110vmax 0 0 -110vmax;
  pointer-events: none;
  opacity: 0.38;
  background: conic-gradient(
    from 0deg,
    transparent 0deg,
    rgba(124, 92, 255, 0.16) 40deg,
    rgba(56, 189, 248, 0.1) 90deg,
    transparent 150deg,
    rgba(236, 72, 153, 0.1) 230deg,
    rgba(167, 139, 250, 0.14) 300deg,
    transparent 360deg
  );
  animation: galaxySpin 120s linear infinite;
}
@keyframes galaxySpin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

/* 星云微光层 —— 缓慢漂浮呼吸 */
.nebula {
  position: fixed;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  background:
    radial-gradient(600px 400px at 18% 28%, rgba(99, 102, 241, 0.18), transparent 70%),
    radial-gradient(500px 380px at 78% 62%, rgba(14, 165, 233, 0.15), transparent 70%);
  animation: nebulaFloat 24s ease-in-out infinite alternate;
}
@keyframes nebulaFloat {
  from {
    transform: translate3d(-3%, -2%, 0) scale(1);
    opacity: 0.85;
  }
  to {
    transform: translate3d(4%, 3%, 0) scale(1.12);
    opacity: 1;
  }
}
.nebula.b {
  animation: nebulaFloatB 32s ease-in-out infinite alternate;
  background:
    radial-gradient(520px 360px at 62% 18%, rgba(236, 72, 153, 0.13), transparent 70%),
    radial-gradient(460px 340px at 25% 78%, rgba(45, 212, 191, 0.1), transparent 70%);
}
@keyframes nebulaFloatB {
  from {
    transform: translate3d(4%, 3%, 0) scale(1.1);
    opacity: 0.8;
  }
  to {
    transform: translate3d(-4%, -4%, 0) scale(1);
    opacity: 1;
  }
}

/* ---------- 布局 ---------- */
.wrap {
  position: relative;
  z-index: 2;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
  gap: 46px;
}

/* 登录成功提示 */
.toast {
  position: fixed;
  left: 50%;
  top: 8%;
  transform: translate(-50%, -16px);
  z-index: 99;
  padding: 12px 26px;
  border-radius: 40px;
  font-size: 14px;
  letter-spacing: 2px;
  color: #fff;
  background: linear-gradient(90deg, #38bdf8, #8b5cf6, #ec4899);
  box-shadow: 0 12px 40px rgba(139, 92, 246, 0.5);
  opacity: 0;
  pointer-events: none;
  transition: all 0.45s cubic-bezier(0.2, 0.8, 0.2, 1);
  display: flex;
  align-items: center;
  gap: 8px;
}
.toast.show {
  opacity: 1;
  transform: translate(-50%, 0);
}

/* 返回顶部星标 */
.back-top {
  position: fixed;
  right: 22px;
  bottom: 22px;
  z-index: 50;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: 1px solid rgba(148, 170, 255, 0.3);
  background: rgba(20, 24, 58, 0.7);
  color: var(--cyan);
  font-size: 18px;
  cursor: pointer;
  display: grid;
  place-items: center;
  opacity: 0;
  pointer-events: none;
  transition: all 0.3s;
  backdrop-filter: blur(8px);
}
.back-top.show {
  opacity: 1;
  pointer-events: auto;
}
.back-top:hover {
  box-shadow: 0 0 22px rgba(56, 189, 248, 0.5);
  transform: translateY(-3px);
}

@media (max-width: 480px) {
  .wrap {
    padding: 32px 16px;
    gap: 32px;
  }
}
</style>
