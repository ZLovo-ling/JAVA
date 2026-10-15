<script setup>
import { ref, inject } from 'vue'
import { login } from '../services/auth'

const notify = inject('notify')

const account = ref('')
const psw = ref('')
const showPsw = ref(false)
const remember = ref(true)

async function onSubmit() {
  const res = await login(account.value, psw.value)
  if (res.ok && res.data) {
    notify(`登录成功，欢迎回来 ${res.data.username || res.data.account}！`)
  } else {
    notify(res.msg)
  }
}

function togglePsw() {
  showPsw.value = !showPsw.value
}

function forgotTip() {
  notify('正在为您开启星光找回通道...')
}
</script>

<template>
  <div class="card">
    <!-- 品牌区 -->
    <div class="brand">
      <div class="logo">
        <div class="logo-ic">✦</div>
      </div>
      <div class="brand-text">星购商城</div>
      <div class="slogan">STAR SHOPPING · 每一次购物都是一场星辰之旅</div>
    </div>
    <div class="stars-divider">✦ ✧ ✦</div>

    <form @submit.prevent="onSubmit">
      <div class="field">
        <label>✦ 账号</label>
        <div class="input-box">
          <span class="input-ic">✉</span>
          <input type="text" v-model="account" placeholder="手机号 / 邮箱" autocomplete="username" />
        </div>
      </div>

      <div class="field">
        <label>✦ 密码</label>
        <div class="input-box">
          <span class="input-ic">🔒</span>
          <input
            :type="showPsw ? 'text' : 'password'"
            v-model="psw"
            placeholder="请输入密码"
            autocomplete="current-password"
          />
          <button
            type="button"
            class="toggle-psw"
            @click="togglePsw"
            :title="showPsw ? '隐藏密码' : '显示密码'"
          >
            {{ showPsw ? '🙈' : '👁' }}
          </button>
        </div>
      </div>

      <div class="row-between">
        <label class="remember">
          <input type="checkbox" v-model="remember" />
          <span>✦ 记住我</span>
        </label>
        <button type="button" class="forgot" @click="forgotTip">忘记密码?</button>
      </div>

      <button type="submit" class="btn-login">
        <span class="twinkle">✦</span> 登 录 <span class="twinkle">✦</span>
      </button>
    </form>

    <div class="third">
      <div class="third-label">其他登录方式</div>
      <div class="third-icons">
        <button type="button" title="微信登录">💬</button>
        <button type="button" title="QQ 登录">🐧</button>
        <button type="button" title="苹果登录"></button>
      </div>
    </div>

    <div class="footer-signup">
      还没有账号？<router-link to="/register">立即注册</router-link>
    </div>
  </div>
</template>

<style scoped>
/* 玻璃拟态登录卡片 */
.card {
  width: 100%;
  max-width: 420px;
  padding: 42px 38px 34px;
  border-radius: 26px;
  position: relative;
  background: linear-gradient(160deg, rgba(30, 35, 80, 0.55), rgba(18, 21, 52, 0.45));
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
  border: 1px solid rgba(148, 170, 255, 0.22);
  box-shadow:
    0 30px 80px rgba(0, 0, 0, 0.55),
    inset 0 1px 0 rgba(255, 255, 255, 0.15),
    0 0 60px rgba(120, 100, 255, 0.1);
  animation: cardIn 0.9s cubic-bezier(0.2, 0.8, 0.2, 1) both;
}
@keyframes cardIn {
  from {
    opacity: 0;
    transform: translateY(26px) scale(0.97);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.card::before {
  content: "";
  position: absolute;
  top: -1px;
  left: 12%;
  width: 76%;
  height: 2px;
  border-radius: 2px;
  background: linear-gradient(90deg, transparent, var(--cyan), var(--violet), var(--pink), transparent);
  opacity: 0.9;
}

/* 品牌区 */
.brand {
  text-align: center;
  margin-bottom: 8px;
}

.logo {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 6px;
}
.logo-ic {
  width: 46px;
  height: 46px;
  display: grid;
  place-items: center;
  border-radius: 14px;
  background: linear-gradient(135deg, #6ee7f9, #8b5cf6 55%, #ec4899);
  box-shadow: 0 8px 24px rgba(139, 92, 246, 0.45);
  font-size: 24px;
  animation: spinSlow 12s linear infinite;
}
@keyframes spinSlow {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.brand-text {
  font-size: 30px;
  letter-spacing: 6px;
  font-weight: 700;
  background: linear-gradient(92deg, var(--cyan) 0%, var(--violet) 45%, var(--pink) 80%, var(--gold) 110%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  filter: drop-shadow(0 0 14px rgba(167, 139, 250, 0.55));
  font-family: "STKaiti", "KaiTi", serif;
}
.slogan {
  margin-top: 10px;
  font-size: 13px;
  letter-spacing: 3px;
  color: transparent;
  background: linear-gradient(90deg, #a5b4fc, #fbcfe8, #a5b4fc);
  background-size: 200% 100%;
  -webkit-background-clip: text;
  background-clip: text;
  animation: sloganFlow 6s linear infinite;
}
@keyframes sloganFlow {
  from {
    background-position: 0% 0;
  }
  to {
    background-position: 200% 0;
  }
}
.stars-divider {
  text-align: center;
  margin: 4px 0 22px;
  font-size: 12px;
  letter-spacing: 12px;
  color: rgba(201, 182, 255, 0.6);
  text-shadow: 0 0 12px rgba(167, 139, 250, 0.8);
}

/* 表单 */
.field {
  margin-bottom: 18px;
  position: relative;
}

.field label {
  display: block;
  font-size: 13px;
  margin-bottom: 7px;
  letter-spacing: 1px;
  color: transparent;
  background: linear-gradient(90deg, #c4b5fd, #e9d5ff);
  -webkit-background-clip: text;
  background-clip: text;
}

.input-box {
  position: relative;
  display: flex;
  align-items: center;
}
.input-ic {
  position: absolute;
  left: 14px;
  font-size: 16px;
  color: #9aa4e8;
}
.input-box input {
  width: 100%;
  padding: 13px 14px 13px 44px;
  font-size: 15px;
  color: #f1f5ff;
  letter-spacing: 1px;
  background: rgba(13, 17, 44, 0.5);
  border: 1px solid rgba(140, 160, 255, 0.22);
  border-radius: 13px;
  outline: none;
  transition: all 0.3s;
  font-family: inherit;
}
.input-box input::placeholder {
  color: rgba(178, 190, 230, 0.45);
}
.input-box input:focus {
  border-color: rgba(167, 139, 250, 0.8);
  box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.18), 0 0 22px rgba(139, 92, 246, 0.3);
  background: rgba(16, 20, 50, 0.65);
}
.toggle-psw {
  position: absolute;
  right: 12px;
  background: none;
  border: none;
  cursor: pointer;
  color: #9aa4e8;
  font-size: 16px;
}
.toggle-psw:hover {
  color: var(--cyan);
}

.row-between {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 2px 0 22px;
  font-size: 12.5px;
}
.remember {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #b9c3f2;
  cursor: pointer;
  user-select: none;
}
.remember input {
  accent-color: #8b5cf6;
  width: 14px;
  height: 14px;
  cursor: pointer;
}
.forgot {
  background: none;
  border: none;
  cursor: pointer;
  color: transparent;
  background: linear-gradient(90deg, #93c5fd, #a78bfa);
  -webkit-background-clip: text;
  background-clip: text;
  font-size: 12.5px;
  letter-spacing: 1px;
}
.forgot:hover {
  text-shadow: 0 0 12px rgba(147, 197, 253, 0.7);
}

/* 登录按钮 */
.btn-login {
  width: 100%;
  padding: 14px;
  border: none;
  border-radius: 14px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 8px;
  color: #fffdf5;
  background: linear-gradient(92deg, #38bdf8 0%, #8b5cf6 48%, #ec4899 100%);
  background-size: 180% 100%;
  box-shadow: 0 10px 30px rgba(139, 92, 246, 0.4);
  transition: all 0.3s;
  font-family: inherit;
}
.btn-login:hover {
  background-position: 100% 0;
  box-shadow: 0 12px 36px rgba(139, 92, 246, 0.6), 0 0 30px rgba(236, 72, 153, 0.35);
  transform: translateY(-2px);
}
.btn-login:active {
  transform: translateY(0);
}
.btn-login .twinkle {
  display: inline-block;
  color: var(--gold);
  text-shadow: 0 0 8px var(--gold);
}

/* 第三方登录 */
.third {
  margin-top: 26px;
  text-align: center;
}
.third-label {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 12px;
  letter-spacing: 2px;
  color: rgba(176, 188, 235, 0.55);
}
.third-label::before,
.third-label::after {
  content: "";
  flex: 1;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(148, 170, 255, 0.35));
}
.third-label::after {
  background: linear-gradient(90deg, rgba(148, 170, 255, 0.35), transparent);
}
.third-icons {
  margin-top: 16px;
  display: flex;
  justify-content: center;
  gap: 26px;
}
.third-icons button {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: 1px solid rgba(148, 170, 255, 0.28);
  cursor: pointer;
  background: rgba(20, 24, 58, 0.55);
  color: #c7d2fe;
  font-size: 17px;
  transition: all 0.3s;
  display: grid;
  place-items: center;
}
.third-icons button:hover {
  color: var(--cyan);
  border-color: var(--cyan);
  box-shadow: 0 0 20px rgba(56, 189, 248, 0.4);
  transform: translateY(-3px);
}

.footer-signup {
  margin-top: 24px;
  text-align: center;
  font-size: 13px;
  color: #b9c3f2;
  letter-spacing: 1px;
}
.footer-signup a {
  color: transparent;
  background: linear-gradient(90deg, var(--cyan), var(--pink));
  -webkit-background-clip: text;
  background-clip: text;
  text-decoration: none;
  font-weight: 600;
}
.footer-signup a:hover {
  text-shadow: 0 0 12px rgba(249, 168, 212, 0.7);
}

@media (max-width: 480px) {
  .card {
    padding: 32px 24px 26px;
  }
}
</style>
