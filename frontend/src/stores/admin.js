import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useAdminStore = defineStore('admin', () => {
  const token = ref(localStorage.getItem('admin_token') || '')
  const adminInfo = ref(null)

  const login = (username, password) => {
    // 模拟登录逻辑
    if (username === 'admin' && password === '123456') {
      token.value = 'mock-jwt-token-123'
      localStorage.setItem('admin_token', token.value)
      adminInfo.value = { username: 'admin', role: 'super_admin' }
      return true
    }
    return false
  }

  const logout = () => {
    token.value = ''
    localStorage.removeItem('admin_token')
    adminInfo.value = null
  }

  return {
    token,
    adminInfo,
    login,
    logout
  }
})
