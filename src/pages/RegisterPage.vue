<script setup>
import { ref, inject, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { register } from '../services/auth'

const notify = inject('notify')
const router = useRouter()

const nickname = ref('')
const account = ref('')
const psw = ref('')
const confirm = ref('')
const code = ref('')
const agree = ref(false)

const showPsw = ref(false)
const showConfirm = ref(false)

const errors = ref({})
const codeCountdown = ref(0)
let codeTimer = null

function validate() {
  const e = {}
  if (!nickname.value.trim()) e.nickname = '请输入昵称'
  const acc = account.value.trim()
  if (!acc) e.account = '请输入手机号或邮箱'
  else if (!/^1[3-9]\d{9}$/.test(acc) && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(acc)) {
    e.account = '账号需为手机号或邮箱格式'
  }
  if (!psw.value) e.psw = '请设置密码'
  else if (psw.value.length < 6) e.psw = '密码至少 6 位'
  if (!confirm.value) e.confirm = '请再次输入密码'
  else if (confirm.value !== psw.value) e.confirm = '两次输入的密码不一致'
  if (!agree.value) e.agree = '请先阅读并同意用户协议'
  errors.value = e
  return Object.keys(e).length === 0
}

function getCode() {
  if (codeCountdown.value > 0) return
  const acc = account.value.trim()
  if (!acc) {
    errors.value = { ...errors.value, account: '请先输入手机号或邮箱' }
    notify('请先输入手机号或邮箱')
    return
  }
  codeCountdown.value = 60
  notify('验证码已发送（演示环境）')
  codeTimer = setInterval(() => {
    codeCountdown.value--
    if (codeCountdown.value <= 0) clearInterval(codeTimer)
  }, 1000)
}

async function onSubmit() {
  if (!validate()) {
    notify('请完善注册信息')
    return
  }
  const res = await register(nickname.value, account.value, psw.value, confirm.value)
  notify(res.msg)
  if (res.ok) setTimeout(() => router.push('/login'), 1400)
}

onUnmounted(() => clearInterval(codeTimer))
</script>

<template>
  <div class="card">
    <!-- 品牌区 -->
    <div class="brand">
      <div class="logo"><div class="logo-ic">✦</div></div>
      <div class="brand-text">星购商城</div>
      <div class="slogan">创建你的星空账户 · 开启星辰购物之旅</div>
    </div>
    <div class="stars-divider">✦ ✧ ✦</div>

    <form @submit.prevent="onSubmit">
      <div class="field">
        <label>✦ 昵称</label>
        <div class="input-box">
          <span class="input-ic">👤</span>
          <input type="text" v-model="nickname" placeholder="设置一个昵称" autocomplete="nickname" />
        </div>
        <p class="err" v-if="errors.nickname">{{ errors.nickname }}</p>
      </div>

      <div class="field">
        <label>✦ 手机号 / 邮箱</label>
        <div class="input-box">
          <span class="input-ic">✉</span>
          <input type="text" v-model="account" placeholder="用于登录与找回密码" autocomplete="username" />
        </div>
        <p class="err" v-if="errors.account">{{ errors.account }}</p>
      </div>

      <div class="field">
        <label>✦ 设置密码</label>
        <div class="input-box">
          <span class="input-ic">🔒</span>
          <input
            :type="showPsw ? 'text' : 'password'"
            v-model="psw"
            placeholder="至少 6 位字符"
            autocomplete="new-password"
          />
          <button type="button" class="toggle-psw" @click="showPsw = !showPsw" :title="showPsw ? '隐藏密码' : '显示密码'">
            {{ showPsw ? '🙈' : '👁' }}
          </button>
        </div>
        <p class="err" v-if="errors.psw">{{ errors.psw }}</p>
      </div>

      <div class="field">
        <label>✦ 确认密码</label>
        <div class="input-box">
          <span class="input-ic">🔒</span>
          <input
            :type="showConfirm ? 'text' : 'password'"
            v-model="confirm"
            placeholder="请再次输入密码"
            autocomplete="new-password"
          />
          <button type="button" class="toggle-psw" @click="showConfirm = !showConfirm" :title="showConfirm ? '隐藏密码' : '显示密码'">
            {{ showConfirm ? '🙈' : '👁' }}
          </button>
        </div>
        <p class="err" v-if="errors.confirm">{{ errors.confirm }}</p>
      </div>

      <div class="field">
        <label>✦ 验证码</label>
        <div class="code-row">
          <div class="input-box">
            <span class="input-ic">⚡</span>
            <input type="text" v-model="code" placeholder="6 位验证码" maxlength="6" />
          </div>
          <button type="button" class="get-code" :disabled="codeCountdown > 0" @click="getCode">
            {{ codeCountdown > 0 ? codeCountdown + 's' : '获取验证码' }}
          </button>
        </div>
        <p class="err" v-if="errors.code">{{ errors.code }}</p>
      </div>

      <label class="agree" :class="{ 'has-err': errors.agree }">
        <input type="checkbox" v-model="agree" />
        <span>✦ 我已阅读并同意《星购用户协议》与《隐私政策》</span>
      </label>
      <p class="err" v-if="errors.agree">{{ errors.agree }}</p>

      <button type="submit" class="btn-login">
        <span class="twinkle">✦</span> 注 册 <span class="twinkle">✦</span>
      </button>
    </form>

    <div class="footer-signup">
      已有账号？<router-link to="/login">立即登录</router-link>
    </div>
  </div>
</template>

<style scoped>
/* 玻璃拟态卡片（与登录页一致） */
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
  from { opacity: 0; transform: translateY(26px) scale(0.97); }
  to { opacity: 1; transform: translateY(0) scale(1); }
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
.brand { text-align: center; margin-bottom: 8px; }
.logo { display: inline-flex; align-items: center; gap: 10px; margin-bottom: 6px; }
.logo-ic {
  width: 46px; height: 46px; display: grid; place-items: center;
  border-radius: 14px;
  background: linear-gradient(135deg, #6ee7f9, #8b5cf6 55%, #ec4899);
  box-shadow: 0 8px 24px rgba(139, 92, 246, 0.45);
  font-size: 24px;
  animation: spinSlow 12s linear infinite;
}
@keyframes spinSlow { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
.brand-text {
  font-size: 30px; letter-spacing: 6px; font-weight: 700;
  background: linear-gradient(92deg, var(--cyan) 0%, var(--violet) 45%, var(--pink) 80%, var(--gold) 110%);
  -webkit-background-clip: text; background-clip: text; color: transparent;
  filter: drop-shadow(0 0 14px rgba(167, 139, 250, 0.55));
  font-family: "STKaiti", "KaiTi", serif;
}
.slogan {
  margin-top: 10px; font-size: 13px; letter-spacing: 3px; color: transparent;
  background: linear-gradient(90deg, #a5b4fc, #fbcfe8, #a5b4fc);
  background-size: 200% 100%;
  -webkit-background-clip: text; background-clip: text;
  animation: sloganFlow 6s linear infinite;
}
@keyframes sloganFlow { from { background-position: 0% 0; } to { background-position: 200% 0; } }
.stars-divider {
  text-align: center; margin: 4px 0 22px; font-size: 12px; letter-spacing: 12px;
  color: rgba(201, 182, 255, 0.6); text-shadow: 0 0 12px rgba(167, 139, 250, 0.8);
}

/* 表单 */
.field { margin-bottom: 16px; position: relative; }
.field label {
  display: block; font-size: 13px; margin-bottom: 7px; letter-spacing: 1px;
  color: transparent; background: linear-gradient(90deg, #c4b5fd, #e9d5ff);
  -webkit-background-clip: text; background-clip: text;
}
.input-box { position: relative; display: flex; align-items: center; }
.input-ic { position: absolute; left: 14px; font-size: 16px; color: #9aa4e8; }
.input-box input {
  width: 100%; padding: 13px 14px 13px 44px; font-size: 15px; color: #f1f5ff;
  letter-spacing: 1px; background: rgba(13, 17, 44, 0.5);
  border: 1px solid rgba(140, 160, 255, 0.22); border-radius: 13px;
  outline: none; transition: all 0.3s; font-family: inherit;
}
.input-box input::placeholder { color: rgba(178, 190, 230, 0.45); }
.input-box input:focus {
  border-color: rgba(167, 139, 250, 0.8);
  box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.18), 0 0 22px rgba(139, 92, 246, 0.3);
  background: rgba(16, 20, 50, 0.65);
}
.toggle-psw {
  position: absolute; right: 12px; background: none; border: none; cursor: pointer;
  color: #9aa4e8; font-size: 16px;
}
.toggle-psw:hover { color: var(--cyan); }

/* 验证码行 */
.code-row { display: flex; gap: 10px; }
.code-row .input-box { flex: 1; }
.get-code {
  flex: 0 0 116px; border-radius: 13px; cursor: pointer;
  border: 1px solid rgba(140, 160, 255, 0.3);
  background: rgba(20, 24, 58, 0.55); color: #c7d2fe;
  font-size: 13px; letter-spacing: 1px; font-family: inherit;
  transition: all 0.3s;
}
.get-code:hover:not(:disabled) {
  color: var(--cyan); border-color: var(--cyan);
  box-shadow: 0 0 16px rgba(56, 189, 248, 0.35);
}
.get-code:disabled { opacity: 0.55; cursor: not-allowed; }

/* 同意条款 */
.agree {
  display: flex; align-items: center; gap: 6px; margin: 2px 0 4px;
  color: #b9c3f2; cursor: pointer; user-select: none; font-size: 12.5px;
}
.agree input { accent-color: #8b5cf6; width: 14px; height: 14px; cursor: pointer; }
.agree.has-err { color: #ff9bb0; }

/* 错误提示 */
.err {
  margin-top: 6px; font-size: 12px; letter-spacing: 0.5px;
  color: #ff9bb0; text-shadow: 0 0 10px rgba(255, 120, 150, 0.4);
}

/* 注册按钮 */
.btn-login {
  width: 100%; padding: 14px; margin-top: 8px; border: none; border-radius: 14px;
  cursor: pointer; font-size: 16px; font-weight: 600; letter-spacing: 8px; color: #fffdf5;
  background: linear-gradient(92deg, #38bdf8 0%, #8b5cf6 48%, #ec4899 100%);
  background-size: 180% 100%;
  box-shadow: 0 10px 30px rgba(139, 92, 246, 0.4); transition: all 0.3s; font-family: inherit;
}
.btn-login:hover {
  background-position: 100% 0;
  box-shadow: 0 12px 36px rgba(139, 92, 246, 0.6), 0 0 30px rgba(236, 72, 153, 0.35);
  transform: translateY(-2px);
}
.btn-login:active { transform: translateY(0); }
.btn-login .twinkle { display: inline-block; color: var(--gold); text-shadow: 0 0 8px var(--gold); }

/* 底部登录入口 */
.footer-signup {
  margin-top: 22px; text-align: center; font-size: 13px; color: #b9c3f2; letter-spacing: 1px;
}
.footer-signup a {
  color: transparent; background: linear-gradient(90deg, var(--cyan), var(--pink));
  -webkit-background-clip: text; background-clip: text; text-decoration: none; font-weight: 600;
}
.footer-signup a:hover { text-shadow: 0 0 12px rgba(249, 168, 212, 0.7); }

@media (max-width: 480px) {
  .card { padding: 32px 24px 26px; }
  .code-row { flex-direction: column; gap: 0; }
  .get-code { flex: none; width: 100%; padding: 11px; margin-top: 8px; }
}
</style>
