<template>
  <div class="client-layout-container">
    <!-- Pure dark layout (no blobs) -->

    <!-- PC Navigation Bar -->
    <header class="client-header glass-nav">
      <div class="header-inner">
        <div class="logo-area" @click="goHome">
          <div class="logo-dot"></div>
          <span class="logo-text">Syne<span class="logo-sub">Tiktok</span></span>
        </div>

        <div class="search-area">
          <div class="glass-search-box">
            <SearchOutlined class="search-icon" />
            <input type="text" placeholder="Search accounts, videos or topics..." v-model="searchQuery" @keyup.enter="handleSearch" />
            <button class="search-btn" @click="handleSearch">Search</button>
          </div>
        </div>

        <div class="actions-area">
          <button class="action-btn upload-btn" @click="openUpload">
            <PlusOutlined /> <span>Upload</span>
          </button>
          
          <div class="icon-badge-btn">
            <BellOutlined />
            <span class="badge">3</span>
          </div>

          <a-dropdown :trigger="['click']" placement="bottomRight" overlayClassName="glass-dropdown">
            <div class="avatar-wrapper">
              <a-avatar class="client-avatar" src="https://api.dicebear.com/7.x/notionists/svg?seed=User" />
            </div>
            <template #overlay>
              <div class="dropdown-card">
                <div class="dropdown-user-info">
                  <span class="dropdown-name">Aix Crimson</span>
                  <span class="dropdown-handle">@aixcrimson</span>
                </div>
                <div class="dropdown-divider"></div>
                <div class="dropdown-item" @click="goProfile">
                  <UserOutlined />
                  <span>My Profile</span>
                </div>
                <div class="dropdown-item" @click="goAdmin">
                  <SettingOutlined />
                  <span>Admin Dashboard</span>
                </div>
                <div class="dropdown-divider"></div>
                <div class="dropdown-item logout" @click="handleLogout">
                  <LogoutOutlined />
                  <span>Log out</span>
                </div>
              </div>
            </template>
          </a-dropdown>
        </div>
      </div>
    </header>

    <!-- Main Content Area -->
    <main class="client-main">
      <router-view v-slot="{ Component }">
        <transition name="fade-slide" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- Mobile Bottom Tab Bar -->
    <nav class="mobile-tab-bar glass-tabs">
      <div class="tab-item" :class="{ active: currentTab === 'home' }" @click="switchTab('home')">
        <HomeOutlined class="tab-icon" />
        <span class="tab-label">Home</span>
      </div>
      <div class="tab-item" :class="{ active: currentTab === 'discover' }" @click="switchTab('discover')">
        <CompassOutlined class="tab-icon" />
        <span class="tab-label">Discover</span>
      </div>
      <div class="tab-item upload" @click="openUpload">
        <div class="mobile-upload-btn">
          <PlusOutlined />
        </div>
      </div>
      <div class="tab-item" :class="{ active: currentTab === 'inbox' }" @click="switchTab('inbox')">
        <div class="icon-container">
          <MessageOutlined class="tab-icon" />
          <span class="badge-dot"></span>
        </div>
        <span class="tab-label">Inbox</span>
      </div>
      <div class="tab-item" :class="{ active: currentTab === 'me' }" @click="switchTab('me')">
        <UserOutlined class="tab-icon" />
        <span class="tab-label">Profile</span>
      </div>
    </nav>

    <!-- Global Video Upload Modal -->
    <UploadModal v-model:open="isUploadOpen" @uploaded="handleVideoUploaded" />
  </div>
</template>

<script setup>
import { ref, computed, provide } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { 
  HomeOutlined, 
  CompassOutlined, 
  PlusOutlined, 
  MessageOutlined, 
  UserOutlined, 
  SearchOutlined, 
  BellOutlined,
  SettingOutlined,
  LogoutOutlined
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import UploadModal from '../components/UploadModal.vue';

const router = useRouter();
const route = useRoute();

const searchQuery = ref('');
const isUploadOpen = ref(false);

const currentTab = computed(() => {
  if (route.path.includes('/user')) return 'me';
  return 'home';
});

// Provide a global event mechanism to open the upload modal from child components
const openUpload = () => {
  isUploadOpen.value = true;
};
provide('openUploadModal', openUpload);

const goHome = () => {
  router.push('/home');
};

const goProfile = () => {
  router.push('/user/aixcrimson');
};

const goAdmin = () => {
  router.push('/admin/audit');
};

const handleLogout = () => {
  message.success('Logged out successfully');
  router.push('/admin/login');
};

const handleSearch = () => {
  if (searchQuery.value.trim()) {
    message.info(`Searching for: ${searchQuery.value}`);
    // Emit custom event if handled inside Home feed
    window.dispatchEvent(new CustomEvent('feed-search', { detail: searchQuery.value }));
  }
};

const switchTab = (tab) => {
  if (tab === 'home') {
    goHome();
  } else if (tab === 'me') {
    goProfile();
  } else {
    message.info(`"${tab.toUpperCase()}" tab features will be integrated soon!`);
  }
};

const handleVideoUploaded = (newVideo) => {
  message.success('Video published successfully!');
  // Dispatch custom event to notify home page to append the newly uploaded video
  window.dispatchEvent(new CustomEvent('video-published', { detail: newVideo }));
};
</script>

<style scoped>
.client-layout-container {
  width: 100%;
  height: 100vh;
  position: relative;
  background: #08090d;
  color: var(--lg-text-primary);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* Static background setup */

/* Navigation Bar */
.client-header {
  position: relative;
  z-index: 50;
  width: 100%;
  height: 72px;
  padding: 0 40px;
  display: flex;
  align-items: center;
}

.glass-nav {
  background: rgba(255, 255, 255, 0.04);
  border-bottom: 1px solid var(--lg-border);
  backdrop-filter: var(--lg-blur-soft);
  -webkit-backdrop-filter: var(--lg-blur-soft);
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.1);
}

.header-inner {
  width: 100%;
  max-width: 1400px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 240px 1fr 280px;
  align-items: center;
  gap: 20px;
}

.logo-area {
  display: flex;
  align-items: center;
  cursor: pointer;
  user-select: none;
}

.logo-dot {
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #ffffff;
  margin-right: 10px;
}

.logo-text {
  font-size: 24px;
  font-weight: 800;
  letter-spacing: -1px;
  color: #ffffff;
}

.logo-sub {
  color: var(--lg-text-secondary);
  margin-left: 2px;
}

/* Search Box */
.search-area {
  display: flex;
  justify-content: center;
}

.glass-search-box {
  display: flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid var(--lg-border);
  border-radius: 999px;
  width: 100%;
  max-width: 460px;
  height: 44px;
  padding: 2px 2px 2px 18px;
  transition: all var(--lg-motion);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.05);
}

.glass-search-box:focus-within {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(102, 217, 255, 0.6);
  box-shadow: 0 0 20px rgba(102, 217, 255, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.1);
}

.search-icon {
  font-size: 16px;
  color: var(--lg-text-muted);
  margin-right: 12px;
}

.glass-search-box input {
  flex: 1;
  background: transparent;
  border: none;
  color: var(--lg-text-primary);
  outline: none;
  font-size: 14px;
}

.glass-search-box input::placeholder {
  color: var(--lg-text-muted);
}

.search-btn {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.08);
  color: var(--lg-text-secondary);
  border-radius: 999px;
  height: 38px;
  padding: 0 20px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--lg-motion);
}

.glass-search-box:focus-within .search-btn {
  background: rgba(255, 255, 255, 0.95);
  border-color: rgba(255, 255, 255, 0.95);
  color: #08090d;
}

.search-btn:hover {
  filter: brightness(1.1);
}

/* Actions Area */
.actions-area {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 22px;
}

.action-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  height: 40px;
  padding: 0 18px;
  border-radius: 12px;
  font-weight: 700;
  font-size: 14px;
  cursor: pointer;
  transition: all var(--lg-motion);
  border: 1px solid var(--lg-border);
}

.upload-btn {
  background: rgba(255, 255, 255, 0.08);
  color: var(--lg-text-primary);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.15);
}

.upload-btn:hover {
  background: rgba(255, 255, 255, 0.16);
  border-color: rgba(255, 255, 255, 0.42);
}

.icon-badge-btn {
  font-size: 20px;
  color: var(--lg-text-secondary);
  cursor: pointer;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.06);
  transition: all var(--lg-motion);
}

.icon-badge-btn:hover {
  color: var(--lg-text-primary);
  background: rgba(255, 255, 255, 0.1);
  transform: scale(1.05);
}

.icon-badge-btn .badge {
  position: absolute;
  top: -4px;
  right: -4px;
  background: #ff2d78;
  color: white;
  font-size: 10px;
  font-weight: 700;
  padding: 1px 6px;
  border-radius: 10px;
  line-height: 12px;
  border: 1.5px solid #04060d;
}

.avatar-wrapper {
  cursor: pointer;
  padding: 2px;
  border-radius: 50%;
  background: transparent;
  border: 1.5px solid transparent;
}

.avatar-wrapper:hover {
  border-color: rgba(255, 255, 255, 0.45);
}

.client-avatar {
  border: 1.5px solid #04060d;
  background: rgba(255, 255, 255, 0.1);
}

/* Ant Dropdown Liquid Glass Custom Styling */
.dropdown-card {
  margin-top: 8px;
  padding: 12px;
  background: rgba(14, 18, 32, 0.72) !important;
  backdrop-filter: blur(28px) saturate(1.8) contrast(1.05);
  -webkit-backdrop-filter: blur(28px) saturate(1.8) contrast(1.05);
  border: 1px solid var(--lg-border-strong);
  border-radius: 20px;
  box-shadow: 0 16px 44px rgba(0, 0, 0, 0.5), inset 0 1px 0 rgba(255, 255, 255, 0.15);
  min-width: 200px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.dropdown-user-info {
  display: flex;
  flex-direction: column;
  padding: 6px 12px 10px;
}

.dropdown-name {
  font-weight: 700;
  color: var(--lg-text-primary);
  font-size: 15px;
}

.dropdown-handle {
  font-size: 12px;
  color: var(--lg-text-muted);
}

.dropdown-divider {
  height: 1px;
  background: rgba(255, 255, 255, 0.08);
  margin: 4px 0;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 14px;
  border-radius: 12px;
  color: var(--lg-text-secondary);
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: all var(--lg-motion);
}

.dropdown-item:hover {
  background: rgba(255, 255, 255, 0.08);
  color: var(--lg-text-primary);
}

.dropdown-item.logout {
  color: #ff5983;
}

.dropdown-item.logout:hover {
  background: rgba(255, 45, 120, 0.12);
  color: #ff386b;
}

/* Main Routing Area */
.client-main {
  flex: 1;
  width: 100%;
  position: relative;
  z-index: 10;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

/* Mobile Bottom Tabbar */
.mobile-tab-bar {
  display: none;
}

/* Router transition effect */
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-slide-enter-from {
  opacity: 0;
  transform: translateY(12px);
}

.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(-12px);
}

/* Responsiveness overrides */
@media (max-width: 720px) {
  .client-header {
    display: none;
  }

  .client-layout-container {
    padding-bottom: 60px; /* height of bottom bar */
  }

  /* Mobile Bottom Navigation style */
  .mobile-tab-bar {
    display: flex;
    position: fixed;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 64px;
    z-index: 99;
    padding: 0 10px;
    justify-content: space-around;
    align-items: center;
  }

  .glass-tabs {
    background: rgba(8, 10, 16, 0.7);
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    backdrop-filter: var(--lg-blur-soft);
    -webkit-backdrop-filter: var(--lg-blur-soft);
    box-shadow: 0 -4px 30px rgba(0, 0, 0, 0.2);
  }

  .tab-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: var(--lg-text-secondary);
    font-size: 11px;
    cursor: pointer;
    flex: 1;
    height: 100%;
    transition: all var(--lg-motion);
    padding-top: 6px;
    position: relative;
  }

  .tab-icon {
    font-size: 20px;
    margin-bottom: 3px;
    transition: transform var(--lg-motion);
  }

  .tab-item:active .tab-icon {
    transform: scale(0.85);
  }

  .tab-item.active {
    color: var(--lg-text-primary);
  }

  .tab-item.active .tab-icon {
    color: #ffffff;
  }

  .tab-label {
    font-weight: 500;
  }

  /* Plus button styling */
  .tab-item.upload {
    padding-top: 0;
  }

  .mobile-upload-btn {
    width: 44px;
    height: 32px;
    background: #fff;
    color: #000;
    border-radius: 9px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: 800;
    border: 1px solid rgba(255, 255, 255, 0.15);
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
    transition: transform var(--lg-motion);
  }

  .tab-item.upload:active .mobile-upload-btn {
    transform: scale(0.9);
  }

  .icon-container {
    position: relative;
    display: flex;
  }

  .badge-dot {
    position: absolute;
    top: 0;
    right: -2px;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #ff2d78;
    box-shadow: 0 0 6px #ff2d78;
    border: 1px solid #000;
  }
}
</style>
