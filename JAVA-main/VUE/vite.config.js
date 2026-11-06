import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// 开发环境：将前端 /api 请求代理到后端 Spring Boot（端口 8081），避免跨域
// 生产环境（npm run build 后由后端托管 dist）使用同源地址，无需代理
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8081',
        changeOrigin: true
      }
    }
  }
})
