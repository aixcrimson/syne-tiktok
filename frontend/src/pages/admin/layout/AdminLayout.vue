<template>
  <div class="admin-layout">
    <!-- Dynamic animated background -->
    <div class="background-layer">
      <div class="blob-1"></div>
      <div class="blob-2"></div>
      <div class="blob-3"></div>
    </div>

    <!-- Dynamic Island (Top Navigation) -->
    <div class="dynamic-island-wrapper">
      <LiquidGlass borderRadius="30px" blur="20px" :opacity="0.2" :edgeRefraction="0.05" :draggable="false" :interactive="true">
        <div class="dynamic-island">
          <div class="logo">
            <span class="logo-icon"></span>
            Syne
          </div>
          
          <a-menu
            v-model:selectedKeys="selectedKeys"
            theme="dark"
            mode="horizontal"
            class="ios-menu"
            @click="handleMenuClick"
            :selectable="true"
          >
            <a-menu-item key="/admin/audit">
              <template #icon><VideoCameraOutlined /></template>
              Audit
            </a-menu-item>
            <a-menu-item key="/admin/comments">
              <template #icon><MessageOutlined /></template>
              Comments
            </a-menu-item>
          </a-menu>
          
          <div class="user-actions">
            <a-avatar class="ios-avatar" src="https://api.dicebear.com/7.x/notionists/svg?seed=Admin" />
            <a-button type="text" class="logout-btn" @click="handleLogout" title="Logout">
              <LogoutOutlined />
            </a-button>
          </div>
        </div>
      </LiquidGlass>
    </div>

    <!-- Main Content Widget -->
    <div class="main-area">
      <div class="content-header">
        <h2 class="page-title">{{ pageTitle }}</h2>
      </div>

      <div class="content-wrapper">
        <LiquidGlass borderRadius="32px" blur="25px" :opacity="0.1" :edgeRefraction="0.08" :draggable="false" :interactive="true" :distortion="false">
          <div class="glass-content-inner">
            <router-view v-slot="{ Component }">
              <transition name="ios-scale" mode="out-in">
                <component :is="Component" />
              </transition>
            </router-view>
          </div>
        </LiquidGlass>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAdminStore } from '@/stores/admin';
import { VideoCameraOutlined, MessageOutlined, LogoutOutlined } from '@ant-design/icons-vue';
import LiquidGlass from '@/components/common/LiquidGlass.vue';

const router = useRouter();
const route = useRoute();
const adminStore = useAdminStore();

const selectedKeys = ref([route.path]);

const pageTitle = computed(() => {
  if (route.path.includes('audit')) return 'Video Audit';
  if (route.path.includes('comments')) return 'Comments';
  return 'Dashboard';
});

watch(() => route.path, (newPath) => {
  selectedKeys.value = [newPath];
});

const handleMenuClick = ({ key }) => {
  router.push(key);
};

const handleLogout = () => {
  adminStore.logout();
  router.push('/admin/login');
};
</script>

<style scoped>
.admin-layout {
  width: 100vw;
  height: 100vh;
  position: relative;
  background-color: #000;
  color: white;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* Background gradient blobs */
.background-layer {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  overflow: hidden;
  filter: blur(80px);
}

.blob-1 {
  position: absolute;
  width: 800px;
  height: 800px;
  background: radial-gradient(circle, rgba(255,42,95,0.4), transparent 60%);
  top: -20%;
  right: -10%;
  animation: float-slow 30s infinite alternate cubic-bezier(0.4, 0, 0.2, 1);
  will-change: transform;
  transform: translateZ(0);
}

.blob-2 {
  position: absolute;
  width: 1000px;
  height: 1000px;
  background: radial-gradient(circle, rgba(0,210,255,0.3), transparent 60%);
  bottom: -30%;
  left: -20%;
  animation: float-slow 25s infinite alternate-reverse cubic-bezier(0.4, 0, 0.2, 1);
  will-change: transform;
  transform: translateZ(0);
}

.blob-3 {
  position: absolute;
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, rgba(100,60,255,0.3), transparent 60%);
  top: 40%;
  left: 30%;
  animation: float-slow 20s infinite alternate cubic-bezier(0.4, 0, 0.2, 1);
  will-change: transform;
  transform: translateZ(0);
}

@keyframes float-slow {
  0% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(100px, 150px) scale(1.1); }
  100% { transform: translate(-50px, -50px) scale(0.9); }
}

/* Dynamic Island */
.dynamic-island-wrapper {
  position: relative;
  z-index: 100;
  width: 640px;
  height: 60px;
  margin-top: 32px;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.dynamic-island-wrapper:hover {
  transform: scale(1.02);
}

.dynamic-island {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
}

.logo {
  display: flex;
  align-items: center;
  font-weight: 700;
  font-size: 18px;
  letter-spacing: -0.5px;
  padding-left: 8px;
}

.logo-icon {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: linear-gradient(135deg, #ff2a5f, #00d2ff);
  margin-right: 8px;
  box-shadow: 0 0 10px rgba(255, 42, 95, 0.8);
}

.ios-menu {
  background: transparent !important;
  border-bottom: none !important;
  line-height: 58px;
  flex: 1;
  justify-content: center;
}

:deep(.ant-menu-dark.ant-menu-horizontal) {
  border-bottom: none;
}

:deep(.ant-menu-dark .ant-menu-item) {
  padding: 0 20px;
  color: rgba(255, 255, 255, 0.6) !important;
  font-weight: 500;
  transition: all 0.3s ease;
  border-radius: 16px;
  margin: 0 4px;
}

:deep(.ant-menu-dark .ant-menu-item:hover) {
  background-color: rgba(255, 255, 255, 0.1) !important;
  color: white !important;
}

:deep(.ant-menu-dark .ant-menu-item-selected) {
  background-color: rgba(255, 255, 255, 0.15) !important;
  color: white !important;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.user-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.ios-avatar {
  background-color: transparent;
  border: 1px solid rgba(255, 255, 255, 0.2);
  cursor: pointer;
  transition: transform 0.2s ease;
}

.ios-avatar:hover {
  transform: scale(1.1);
}

.logout-btn {
  color: rgba(255, 255, 255, 0.6);
  border-radius: 50%;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  transition: all 0.2s ease;
}

.logout-btn:hover {
  background: rgba(255, 60, 60, 0.2);
  color: #ff4d4f;
}

/* Main Area */
.main-area {
  flex: 1;
  width: 100%;
  max-width: 1200px;
  display: flex;
  flex-direction: column;
  position: relative;
  z-index: 10;
  padding: 32px 24px;
  min-height: 0;
}

.content-header {
  margin-bottom: 24px;
  padding-left: 16px;
}

.page-title {
  font-size: 32px;
  font-weight: 700;
  margin: 0;
  color: white;
  letter-spacing: -1px;
}

.content-wrapper {
  flex: 1;
  width: 100%;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  min-height: 0;
  transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.content-wrapper:hover {
  transform: translateY(-2px);
}

.glass-content-inner {
  width: 100%;
  height: 100%;
  padding: 32px;
  overflow-y: auto;
  overflow-x: hidden;
  box-sizing: border-box;
}

/* Custom scrollbar */
.glass-content-inner::-webkit-scrollbar {
  width: 6px;
}
.glass-content-inner::-webkit-scrollbar-track {
  background: transparent;
}
.glass-content-inner::-webkit-scrollbar-thumb {
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 3px;
}
.glass-content-inner::-webkit-scrollbar-thumb:hover {
  background-color: rgba(255, 255, 255, 0.4);
}

/* iOS App scaling transition */
.ios-scale-enter-active,
.ios-scale-leave-active {
  transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
}

.ios-scale-enter-from {
  opacity: 0;
  transform: scale(0.96) translateY(10px);
}

.ios-scale-leave-to {
  opacity: 0;
  transform: scale(1.04);
}
</style>
