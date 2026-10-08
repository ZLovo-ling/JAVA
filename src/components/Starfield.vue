<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const canvas = ref(null)
let ctx
let W, H, DPR
let stars = []
let bright = []
let shooting = null
let rafId = null

const COLORS = ['#ffffff', '#cfe6ff', '#fff3c4', '#e5d9ff', '#bff3ff', '#ffd9ec']

function resize() {
  const cv = canvas.value
  DPR = Math.min(window.devicePixelRatio || 1, 2)
  W = cv.width = innerWidth * DPR
  H = cv.height = innerHeight * DPR
  cv.style.width = innerWidth + 'px'
  cv.style.height = innerHeight + 'px'
  buildStars()
}

function buildStars() {
  const count = Math.floor((innerWidth * innerHeight) / 2400)
  stars = []
  for (let i = 0; i < count; i++) {
    const lv = Math.random()
    let layer, r, drift
    if (lv < 0.62) {
      layer = 0
      r = Math.random() * 0.5 + 0.25
      drift = Math.random() * 0.06 + 0.02
    } else if (lv < 0.92) {
      layer = 1
      r = Math.random() * 0.6 + 0.7
      drift = Math.random() * 0.12 + 0.07
    } else {
      layer = 2
      r = Math.random() * 0.8 + 1.3
      drift = Math.random() * 0.2 + 0.16
    }

    stars.push({
      x: Math.random() * W,
      y: Math.random() * H,
      r: r * DPR,
      layer,
      drift: drift * DPR,
      alpha: layer === 0 ? 0.45 : layer === 1 ? 0.7 : 0.95,
      tw: Math.random() * Math.PI * 2,
      speed: Math.random() * 0.9 + 0.3,
      color: COLORS[(Math.random() * COLORS.length) | 0]
    })
  }
  // 取最亮的若干颗用于星群连线
  bright = stars.filter((s) => s.layer === 2).slice(0, 26)
}

function spawnShooting() {
  shooting = {
    x: W * (0.1 + Math.random() * 0.75),
    y: H * (0.03 + Math.random() * 0.28),
    vx: (3.2 + Math.random() * 2.4) * DPR,
    vy: (1.9 + Math.random() * 1.8) * DPR,
    life: 1
  }
}

let t = 0
function draw() {
  t += 0.016
  ctx.clearRect(0, 0, W, H)

  /* 星群连线：随时间缓慢移动重组 */
  ctx.strokeStyle = 'rgba(167, 139, 250, .16)'
  ctx.lineWidth = 0.8 * DPR
  for (let i = 0; i < bright.length; i++) {
    const a = bright[i]
    for (let j = i + 1; j < bright.length; j++) {
      const b = bright[j]
      const dx = a.x - b.x
      const dy = a.y - b.y
      const d2 = dx * dx + dy * dy
      if (d2 < 42000 * DPR * DPR) {
        const d = Math.sqrt(d2)
        ctx.globalAlpha = (1 - d / (205 * DPR)) * 0.3
        ctx.beginPath()
        ctx.moveTo(a.x, a.y)
        ctx.lineTo(b.x, b.y)
        ctx.stroke()
      }
    }
  }

  /* 星星：横向漂移 + 呼吸闪烁 */
  for (const s of stars) {
    s.x -= s.drift
    if (s.x < -8) {
      s.x = W + 8
      s.y = Math.random() * H
    }

    const a = (Math.sin(t * s.speed + s.tw) + 1) / 2
    ctx.globalAlpha = s.alpha * (0.35 + a * 0.65)
    ctx.fillStyle = s.color
    ctx.beginPath()
    ctx.arc(s.x, s.y, s.r + a * 0.7, 0, Math.PI * 2)
    ctx.fill()

    if (s.layer >= 1 && a > 0.55) {
      ctx.globalAlpha = a * 0.22
      ctx.beginPath()
      ctx.arc(s.x, s.y, s.r * (1.6 + a * 1.8), 0, Math.PI * 2)
      ctx.fill()
    }
  }

  /* 流星 */
  if (!shooting && Math.random() < 0.006) spawnShooting()
  if (shooting) {
    shooting.x += shooting.vx
    shooting.y += shooting.vy
    shooting.life -= 0.014
    if (shooting.life <= 0 || shooting.x > W + 400 || shooting.y > H + 400) {
      shooting = null
    } else {
      const hx = shooting.x
      const hy = shooting.y
      const tx = hx - shooting.vx * 5
      const ty = hy - shooting.vy * 5
      ctx.globalAlpha = 0.95
      ctx.lineCap = 'round'
      const g = ctx.createLinearGradient(hx, hy, tx, ty)
      g.addColorStop(0, 'rgba(255, 250, 232, .95)')
      g.addColorStop(0.35, 'rgba(253, 230, 138, .6)')
      g.addColorStop(1, 'rgba(253, 230, 138, 0)')
      ctx.strokeStyle = g
      ctx.lineWidth = 2.2 * DPR
      ctx.beginPath()
      ctx.moveTo(hx, hy)
      ctx.lineTo(tx, ty)
      ctx.stroke()

      ctx.globalAlpha = 0.9
      ctx.fillStyle = '#fffae8'
      ctx.beginPath()
      ctx.arc(hx, hy, 2.4 * DPR, 0, Math.PI * 2)
      ctx.fill()
      ctx.globalAlpha = 0.35
      ctx.beginPath()
      ctx.arc(hx, hy, 7 * DPR, 0, Math.PI * 2)
      ctx.fill()
    }
  }

  ctx.globalAlpha = 1
  rafId = requestAnimationFrame(draw)
}

onMounted(() => {
  ctx = canvas.value.getContext('2d')
  resize()
  window.addEventListener('resize', resize)
  rafId = requestAnimationFrame(draw)
})

onUnmounted(() => {
  cancelAnimationFrame(rafId)
  window.removeEventListener('resize', resize)
})
</script>

<template>
  <canvas ref="canvas" class="starfield"></canvas>
</template>

<style scoped>
.starfield {
  position: fixed;
  inset: 0;
  z-index: 1;
  width: 100%;
  height: 100%;
  pointer-events: none;
}
</style>
