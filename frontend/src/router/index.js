import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    component: () => import('@/pages/client/layout/ClientLayout.vue'),
    redirect: '/home',
    children: [
      {
        path: 'home',
        name: 'Home',
        component: () => import('@/pages/client/home/index.vue')
      },
      {
        path: 'user/:id',
        name: 'UserProfile',
        component: () => import('@/pages/client/profile/index.vue')
      }
    ]
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
