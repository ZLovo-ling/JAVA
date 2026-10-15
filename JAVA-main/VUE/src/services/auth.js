// 真实后端鉴权：调用 Spring Boot 提供的 /api/auth 接口
// 后端项目：D:\workSpace\springBootTest （端口 8081）
// 开发环境通过 Vite 代理（见 vite.config.js）把 /api 转发到 http://localhost:8081
// 统一返回结构 ApiResult：{ code:200 成功 / 其他 失败, message, data }

const BASE = '/api/auth'

async function postJson(url, body) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  })
  let data = null
  try {
    data = await res.json()
  } catch (e) {
    data = null
  }
  if (data && data.code === 200) {
    return { ok: true, msg: data.message || '操作成功', data: data.data }
  }
  return { ok: false, msg: (data && data.message) || `请求失败(${res.status})` }
}

/**
 * 登录
 * @returns {Promise<{ok:boolean,msg:string,data?:object}>}
 */
export async function login(account, psw) {
  const acc = (account || '').trim()
  if (!acc) return { ok: false, msg: '请先输入账号' }
  if (!psw) return { ok: false, msg: '请先输入密码' }
  return postJson(`${BASE}/login`, { account: acc, password: psw })
}

/**
 * 注册
 * @returns {Promise<{ok:boolean,msg:string}>}
 */
export async function register(username, account, psw, confirm) {
  const acc = (account || '').trim()
  if (!acc) return { ok: false, msg: '请输入手机号或邮箱' }
  if (!psw || psw.length < 6) return { ok: false, msg: '密码至少 6 位' }
  if (psw !== confirm) return { ok: false, msg: '两次输入的密码不一致' }
  return postJson(`${BASE}/register`, {
    username: (username || '').trim() || acc,
    account: acc,
    password: psw,
    confirmPassword: confirm
  })
}
