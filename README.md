# ✦ 星购商城登录页（Vue 3 + Vite）

一个以「星空购物」为主题的星购商城登录页面，使用 Vue 3 + Vite 构建。
整体视觉与交互与原版 HTML 保持一致：动态星空粒子背景（含星群连线、流星）、
缓慢旋转的银河光带、漂浮星云、发光月亮，以及玻璃拟态登录卡片与网站用途介绍区。

## 项目结构

```
starshop-login-vue/
├── index.html              # 入口 HTML
├── package.json            # 依赖与脚本
├── vite.config.js          # Vite 配置
└── src/
    ├── main.js             # 应用入口（挂载 router）
    ├── style.css           # 全局样式与主题色变量
    ├── App.vue             # 根组件（背景层 / 布局 / Toast / 返回顶部）
    ├── router/
    │   └── index.js        # Vue Router 路由表（/login、/register）
    ├── pages/
    │   ├── LoginPage.vue   # 登录页（组合 LoginCard + UsageSection）
    │   └── RegisterPage.vue# 注册页（账号 / 密码 / 确认 / 验证码 / 协议）
    └── components/
        ├── Starfield.vue   # Canvas 星空粒子系统（漂移 + 闪烁 + 流星）
        ├── Moon.vue        # 发光月亮
        ├── LoginCard.vue   # 登录卡片（表单 / 第三方登录）
        └── UsageSection.vue# 网站用途简介区
```

## 本地运行

```bash
# 安装依赖
npm install

# 启动开发服务器（默认 http://localhost:5173）
npm run dev

# 构建生产版本（输出到 dist/）
npm run build

# 预览生产构建
npm run preview
```

## 说明

- 已使用 Vue Router 拆分 **登录页（`/login`）** 与 **注册页（`/register`）**，
  访问 `/` 会自动重定向到 `/login`；两页共享同一套星空背景与全局 Toast。
- 注册页包含：账号（手机号/邮箱格式校验）、设置密码（≥6 位）、确认密码、
  验证码（带 60s 倒计时获取）、同意协议勾选，以及完整的内联错误提示；
  注册成功后会自动跳回登录页。
- 登录 / 注册已接入 **前端 mock 鉴权**（`src/services/auth.js`，基于 `localStorage`）：
  注册成功的账号会真实保存，登录时按「账号 + 密码」校验；重复注册、账号不存在、
  密码错误都会给出对应提示，形成完整闭环。
- 账号以明文存于 localStorage，**仅用于本地演示，切勿用于生产**。要接真实后端时，
  只需把 `auth.js` 里的 `register` / `login` 替换为 `fetch` / `axios` 请求即可，
  组件调用方式无需改动。
