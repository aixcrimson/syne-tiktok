<template>
  <div class="admin-layout">
    <!-- Pure deep dark background (no blobs) -->

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
  background: #08090d;
  color: var(--lg-text-primary);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* Static layout setup */

.dynamic-island-wrapper {
  position: relative;
  z-index: 100;
  width: min(680px, calc(100vw - 32px));
  height: 60px;
  margin-top: 32px;
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
  background: rgba(255, 255, 255, 0.85);
  margin-right: 8px;
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
  color: var(--lg-text-secondary) !important;
  font-weight: 500;
  transition: all 0.3s ease;
  border-radius: 16px;
  margin: 0 4px;
}

:deep(.ant-menu-dark .ant-menu-item:hover) {
  background-color: var(--lg-surface-soft) !important;
  color: white !important;
}

:deep(.ant-menu-dark .ant-menu-item-selected) {
  background-color: var(--lg-surface-medium) !important;
  color: white !important;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.18), 0 8px 22px rgba(0, 0, 0, 0.18);
}

.user-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.ios-avatar {
  background-color: transparent;
  border: 1px solid var(--lg-border);
  cursor: pointer;
  transition: transform 0.2s ease;
}

.ios-avatar:hover {
  transform: scale(1.1);
}

.logout-btn {
  color: var(--lg-text-secondary);
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
  color: var(--lg-text-primary);
  letter-spacing: -1px;
}

.content-wrapper {
  flex: 1;
  width: 100%;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  min-height: 0;
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
  background-color: rgba(255, 255, 255, 0.18);
  border-radius: 3px;
}
.glass-content-inner::-webkit-scrollbar-thumb:hover {
  background-color: rgba(255, 255, 255, 0.34);
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

@media (max-width: 720px) {
  .dynamic-island-wrapper {
    height: auto;
    min-height: 60px;
    margin-top: 16px;
  }

  .dynamic-island {
    flex-wrap: wrap;
    gap: 8px;
    padding: 10px 12px;
  }

  .logo {
    flex: 1;
    min-width: 88px;
  }

  .ios-menu {
    order: 3;
    width: 100%;
    flex-basis: 100%;
    line-height: 44px;
  }

  :deep(.ant-menu-dark .ant-menu-item) {
    padding: 0 12px;
    margin: 0 2px;
  }

  .main-area {
    padding: 20px 14px;
  }

  .content-header {
    margin-bottom: 16px;
    padding-left: 6px;
  }

  .page-title {
    font-size: 26px;
  }

  .glass-content-inner {
    padding: 18px;
  }
}
</style>
