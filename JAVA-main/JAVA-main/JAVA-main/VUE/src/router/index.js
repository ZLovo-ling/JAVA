import { createRouter, createWebHistory } from 'vue-router'
import LoginPage from '../pages/LoginPage.vue'
import RegisterPage from '../pages/RegisterPage.vue'
import HomePage from '../pages/HomePage.vue'

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', name: 'login', component: LoginPage },
  { path: '/register', name: 'register', component: RegisterPage },
  { path: '/home', name: 'home', component: HomePage, meta: { requiresAuth: true } }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 需要登录态的页面：未登录（sessionStorage 无 starshop_user）时打回登录页
router.beforeEach((to) => {
  if (to.meta && to.meta.requiresAuth) {
    let user = null
    try {
      user = sessionStorage.getItem('starshop_user')
    } catch (e) {
      user = null
    }
    if (!user) {
      return { path: '/login' }
    }
  }
})

export default router
