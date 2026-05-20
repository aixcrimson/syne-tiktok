import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/admin/login'
  },
  {
    path: '/admin/login',
    name: 'AdminLogin',
    component: () => import('@/pages/admin/login/index.vue')
  },
  {
    path: '/admin',
    name: 'AdminLayout',
    component: () => import('@/pages/admin/layout/AdminLayout.vue'),
    redirect: '/admin/audit',
    children: [
      {
        path: 'audit',
        name: 'AdminAudit',
        component: () => import('@/pages/admin/audit/index.vue')
      },
      {
        path: 'comments',
        name: 'AdminComments',
        component: () => import('@/pages/admin/comments/index.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
