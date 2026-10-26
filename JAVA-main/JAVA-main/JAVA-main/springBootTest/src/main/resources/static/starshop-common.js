/* ============================================================
 * StarShop 公共前端脚本（星空主题）
 * 提供：星空粒子动画、API 请求封装、登录态校验、顶部导航、购物车角标
 * 所有页面统一 <script src="starshop-common.js"></script> 引入
 * ============================================================ */

/* ---------- 1. API 基础地址 ---------- */
function API_BASE() {
  // 同源（被 Spring Boot 8081 托管）用相对路径；file:// 直接打开回退到 localhost:8081
  if (location.protocol === 'file:') return 'http://localhost:8081';
  return '';
}
async function getJson(url, params) {
  let u = API_BASE() + url;
  if (params) {
    const qs = new URLSearchParams(params).toString();
    if (qs) u += (u.includes('?') ? '&' : '?') + qs;
  }
  const r = await fetch(u, { credentials: 'include' });
  const j = await r.json();
  if (j.code !== 200) throw new Error(j.message || '请求失败');
  return j.data;
}
async function postJson(url, body) {
  const r = await fetch(API_BASE() + url, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    credentials: 'include', body: JSON.stringify(body || {})
  });
  const j = await r.json();
  if (j.code !== 200) throw new Error(j.message || '请求失败');
  return j.data;
}
async function putJson(url, body) {
  const r = await fetch(API_BASE() + url, {
    method: 'PUT', headers: { 'Content-Type': 'application/json' },
    credentials: 'include', body: JSON.stringify(body || {})
  });
  const j = await r.json();
  if (j.code !== 200) throw new Error(j.message || '请求失败');
  return j.data;
}
async function deleteJson(url) {
  const r = await fetch(API_BASE() + url, { method: 'DELETE', credentials: 'include' });
  const j = await r.json();
  if (j.code !== 200) throw new Error(j.message || '请求失败');
  return j.data;
}

/* ---------- 2. 当前登录用户（沿用 login 页写入 sessionStorage 的 user.id/user.name） ---------- */
function getCurrentUser() {
  try { return JSON.parse(sessionStorage.getItem('starshop_user') || 'null'); }
  catch (e) { return null; }
}
function requireLogin(redirect) {
  const u = getCurrentUser();
  if (!u || !u.id) { location.href = (redirect || 'starshop-login.html'); return null; }
  return u;
}

/* ---------- 3. 顶部导航（星空风格，统一所有页面） ---------- */
function renderNav(active) {
  const u = getCurrentUser();
  const nav = document.getElementById('topnav');
  if (!nav) return;
  nav.className = 'navbar';
  const items = [
    { key: 'home',     label: '首页',     href: 'starshop-home.html' },
    { key: 'category', label: '商品分类', href: 'starshop-category.html' },
    { key: 'seckill',  label: '限时秒杀', href: 'starshop-seckill.html' },
    { key: 'cart',     label: '购物车',   href: 'starshop-cart.html' },
    { key: 'orders',   label: '我的订单', href: 'starshop-orders.html' }
  ];
  const uname = u ? (u.name || u.email || ('用户' + u.id)) : '';
  nav.innerHTML = `
    <div class="nav-inner">
      <a class="brand" href="starshop-home.html"><span class="brand-star">✦</span> 星河商城<small>STARSHOP</small></a>
      <nav class="nav-links">
        ${items.map(i => `<a href="${i.href}" class="${i.key === active ? 'active' : ''}">${i.label}</a>`).join('')}
      </nav>
      <div class="nav-user">
        <a class="cart-link" href="starshop-cart.html">🛒 购物车
          <span id="cartBadge" class="cart-badge"><span class="dot" hidden>0</span></span>
        </a>
        ${
          u
            ? `<span class="uname">👤 ${uname}</span>
               <a class="logout-btn" href="javascript:void(0)" onclick="doLogout()">退出</a>`
            : `<a class="login-btn" href="starshop-login.html">登录</a>`
        }
      </div>
    </div>`;
  updateCartBadge();
}
function doLogout() {
  sessionStorage.removeItem('starshop_user');
  location.href = 'starshop-login.html';
}
async function updateCartBadge() {
  const u = getCurrentUser();
  const dot = document.querySelector('#cartBadge .dot');
  if (!dot) return;
  if (!u || !u.id) { dot.hidden = true; return; }
  try {
    const list = await getJson('/api/cart', { userId: u.id });
    const n = (list || []).reduce((s, c) => s + (c.quantity || 0), 0);
    if (n > 0) { dot.textContent = n; dot.hidden = false; }
    else dot.hidden = true;
  } catch (e) { dot.hidden = true; }
}

/* ---------- 4. 星空粒子背景（复用登录页效果） ---------- */
function initStarfield(canvasId) {
  const cv = document.getElementById(canvasId || 'starfield');
  if (!cv) return;
  const ctx = cv.getContext('2d');
  let w, h, stars;
  function resize() {
    w = cv.width = window.innerWidth;
    h = cv.height = window.innerHeight;
    const count = Math.min(220, Math.floor(w * h / 9000));
    stars = Array.from({ length: count }, () => ({
      x: Math.random() * w, y: Math.random() * h,
      r: Math.random() * 1.6 + 0.3,
      a: Math.random() * 0.6 + 0.3,
      tw: Math.random() * 0.02 + 0.005,
      vx: (Math.random() - 0.5) * 0.12,
      vy: (Math.random() - 0.5) * 0.12
    }));
  }
  function draw() {
    ctx.clearRect(0, 0, w, h);
    for (const s of stars) {
      s.x += s.vx; s.y += s.vy;
      if (s.x < 0 || s.x > w) s.vx *= -1;
      if (s.y < 0 || s.y > h) s.vy *= -1;
      s.a += s.tw;
      const alpha = 0.35 + Math.abs(Math.sin(s.a)) * 0.55;
      ctx.beginPath();
      ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(180,210,255,${alpha})`;
      ctx.shadowBlur = 6; ctx.shadowColor = 'rgba(120,170,255,0.8)';
      ctx.fill();
    }
    requestAnimationFrame(draw);
  }
  resize();
  window.addEventListener('resize', resize);
  draw();
}

/* ---------- 5. 通用 toast 提示 ---------- */
function toast(msg, type) {
  let t = document.getElementById('toast');
  if (!t) {
    t = document.createElement('div');
    t.id = 'toast';
    t.style.cssText = 'position:fixed;left:50%;bottom:48px;transform:translateX(-50%);' +
      'padding:10px 20px;border-radius:24px;font-size:14px;z-index:9999;color:#fff;' +
      'background:rgba(30,41,95,.92);box-shadow:0 8px 30px rgba(0,0,0,.4);backdrop-filter:blur(6px);' +
      'border:1px solid rgba(140,170,255,.4);transition:opacity .25s;';
    document.body.appendChild(t);
  }
  t.textContent = msg;
  t.style.borderColor = type === 'error' ? 'rgba(255,120,140,.7)' : 'rgba(140,170,255,.4)';
  t.style.opacity = '1';
  clearTimeout(t._timer);
  t._timer = setTimeout(() => { t.style.opacity = '0'; }, 1800);
}

/* ---------- 6. 货币格式化 ---------- */
function money(n) { return '¥' + (Number(n || 0).toFixed(2)); }
