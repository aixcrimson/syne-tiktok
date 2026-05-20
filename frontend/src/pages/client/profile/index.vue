<template>
  <div class="profile-page-container">
    <!-- Go back button for mobile -->
    <div class="mobile-top-bar">
      <button class="back-btn" @click="goBack">
        <ArrowLeftOutlined />
      </button>
      <span class="user-handle">@aixcrimson</span>
    </div>

    <div class="profile-scroll-content">
      <!-- Profile Glass Info Card -->
      <div class="info-card-wrapper">
        <LiquidGlass :opacity="0.1" :blur="'24px'" :distortion="true" borderRadius="24px">
          <div class="user-info-panel">
            <div class="user-main-row">
              <div class="avatar-glow-wrapper">
                <a-avatar :src="'https://api.dicebear.com/7.x/notionists/svg?seed=User'" class="profile-avatar" />
              </div>
              
              <div class="user-text-details">
                <h1 class="user-display-name">Aix Crimson</h1>
                <span class="user-unique-id">@aixcrimson</span>
                
                <div class="user-action-buttons">
                  <button class="btn btn-primary" @click="editProfile">
                    <EditOutlined /> <span>Edit Profile</span>
                  </button>
                  <button class="btn btn-secondary" @click="goToAdmin">
                    <span>Admin Dashboard</span>
                  </button>
                </div>
              </div>
            </div>

            <!-- Stats Bar -->
            <div class="user-stats-bar">
              <div class="stat-item">
                <span class="stat-value">186</span>
                <span class="stat-label">Following</span>
              </div>
              <div class="stat-item">
                <span class="stat-value">254.8K</span>
                <span class="stat-label">Followers</span>
              </div>
              <div class="stat-item">
                <span class="stat-value">1.8M</span>
                <span class="stat-label">Likes</span>
              </div>
            </div>

            <p class="user-bio">
              UI/UX Designer & Creative Frontend Developer. <br />
              Building the future of web with liquid glass glassmorphism. ✨ Enjoying the light refraction & fluid motions!
            </p>
          </div>
        </LiquidGlass>
      </div>

      <!-- Video Grid Tabs -->
      <div class="profile-tabs-wrapper">
        <div class="glass-tabs-nav">
          <div 
            class="tab-nav-item" 
            :class="{ 'active': activeTab === 'videos' }"
            @click="activeTab = 'videos'"
          >
            <span>Videos</span>
          </div>
          <div 
            class="tab-nav-item" 
            :class="{ 'active': activeTab === 'liked' }"
            @click="activeTab = 'liked'"
          >
            <span>Liked</span>
          </div>
          <div 
            class="tab-nav-item" 
            :class="{ 'active': activeTab === 'private' }"
            @click="activeTab = 'private'"
          >
            <LockOutlined class="lock-icon" />
            <span>Private</span>
          </div>
        </div>

        <!-- Video Grid content -->
        <div class="video-grid-container">
          <div v-if="filteredVideos.length === 0" class="empty-videos">
            <PlayCircleOutlined class="empty-icon" />
            <p>No videos available in this category yet.</p>
          </div>

          <div v-else class="video-grid">
            <div 
              v-for="video in filteredVideos" 
              :key="video.id" 
              class="video-grid-card"
              @click="previewVideo(video)"
              @mouseenter="onCardMouseEnter(video.id)"
              @mouseleave="onCardMouseLeave(video.id)"
            >
              <!-- Video preview element (plays on hover) -->
              <div class="video-preview-wrapper">
                <video 
                  :id="`preview-video-${video.id}`"
                  :src="video.videoUrl"
                  muted
                  loop
                  playsinline
                  class="preview-video-el"
                ></video>
                <div class="cover-image" :style="{ backgroundImage: `url(${video.cover})` }"></div>
              </div>

              <!-- Hover Glow Card border -->
              <div class="card-glow-overlay"></div>

              <!-- Stats overlay -->
              <div class="card-stats-row">
                <span class="card-likes">
                  <HeartFilled class="heart-icon" /> {{ formatNumber(video.likes) }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Video Playback Modal Overlay -->
    <div v-if="previewingVideo" class="video-player-overlay">
      <div class="backdrop" @click="closePreview"></div>
      <div class="player-container">
        <LiquidGlass :opacity="0.14" :blur="'30px'" :distortion="true" borderRadius="24px">
          <div class="player-content-wrapper">
            <div class="player-header">
              <span class="player-title">{{ previewingVideo.title }}</span>
              <button class="close-btn" @click="closePreview">
                <CloseOutlined />
              </button>
            </div>
            <div class="player-video-box">
              <video :src="previewingVideo.videoUrl" controls autoplay class="main-video-player"></video>
            </div>
            <div class="player-info-footer">
              <span class="author-tag">@{{ previewingVideo.author }}</span>
              <p class="desc">{{ previewingVideo.description }}</p>
            </div>
          </div>
        </LiquidGlass>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { 
  EditOutlined, 
  HeartFilled, 
  LockOutlined, 
  PlayCircleOutlined, 
  ArrowLeftOutlined, 
  CloseOutlined 
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import LiquidGlass from '@/components/common/LiquidGlass.vue';

const router = useRouter();
const activeTab = ref('videos');
const previewingVideo = ref(null);

// Listening for dynamic upload update from other tabs
const myUploadedVideos = ref([]);

const mockMyVideos = [
  { id: 'V005', cover: 'https://picsum.photos/id/50/200/300', videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-woman-working-on-a-laptop-in-a-cafe-43028-large.mp4', title: 'Liquid Glass Tutorial', author: 'aixcrimson', likes: 128450, category: 'videos' },
  { id: 'V003', cover: 'https://picsum.photos/id/30/200/300', videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-typing-on-a-backlit-keyboard-in-the-dark-44026-large.mp4', title: 'How to code in Vue 3', author: 'aixcrimson', likes: 45000, category: 'videos' }
];

const mockLikedVideos = [
  { id: 'V001', cover: 'https://picsum.photos/id/10/200/300', videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-forest-stream-in-the-sunlight-529-large.mp4', title: 'Amazing Nature Scenery', author: 'nature_lover', likes: 58000, category: 'liked' },
  { id: 'V002', cover: 'https://picsum.photos/id/20/200/300', videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-playful-cat-lying-on-a-carpet-43286-large.mp4', title: 'Funny Cat Compilation', author: 'cat_memes', likes: 2314000, category: 'liked' }
];

onMounted(() => {
  // Sync if there is any local storage published video or listening to events
  window.addEventListener('video-published', (e) => {
    if (e.detail) {
      // Map it to profile layout
      myUploadedVideos.value.unshift({
        ...e.detail,
        likes: 0,
        category: 'videos'
      });
    }
  });
});

const allVideos = computed(() => {
  return [...myUploadedVideos.value, ...mockMyVideos, ...mockLikedVideos];
});

const filteredVideos = computed(() => {
  if (activeTab.value === 'videos') {
    return [...myUploadedVideos.value, ...mockMyVideos];
  } else if (activeTab.value === 'liked') {
    return mockLikedVideos;
  }
  return []; // Private
});

const goBack = () => {
  router.push('/home');
};

const editProfile = () => {
  message.info('Profile customization is coming soon in next beta!');
};

const goToAdmin = () => {
  router.push('/admin/audit');
};

const previewVideo = (video) => {
  previewingVideo.value = video;
};

const closePreview = () => {
  previewingVideo.value = null;
};

const onCardMouseEnter = (id) => {
  const videoEl = document.getElementById(`preview-video-${id}`);
  if (videoEl) {
    videoEl.play().catch(() => {});
  }
};

const onCardMouseLeave = (id) => {
  const videoEl = document.getElementById(`preview-video-${id}`);
  if (videoEl) {
    videoEl.pause();
    videoEl.currentTime = 0; // Rewind
  }
};

const formatNumber = (num) => {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M';
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K';
  }
  return num.toString();
};
</script>

<style scoped>
.profile-page-container {
  display: flex;
  flex-direction: column;
  flex: 1;
  width: 100%;
  max-width: 960px;
  margin: 0 auto;
  padding: 32px 24px 80px;
  height: 100%;
  position: relative;
  min-height: 0;
}

.mobile-top-bar {
  display: none;
}

.profile-scroll-content {
  flex: 1;
  overflow-y: auto;
  padding-right: 4px;
}

/* Custom scrollbar inside profile */
.profile-scroll-content::-webkit-scrollbar {
  width: 6px;
}

.profile-scroll-content::-webkit-scrollbar-track {
  background: transparent;
}

.profile-scroll-content::-webkit-scrollbar-thumb {
  background-color: rgba(255, 255, 255, 0.08);
  border-radius: 10px;
}

.profile-scroll-content::-webkit-scrollbar-thumb:hover {
  background-color: rgba(255, 255, 255, 0.2);
}

/* User Card Panel */
.info-card-wrapper {
  width: 100%;
  margin-bottom: 32px;
}

.user-info-panel {
  padding: 36px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.user-main-row {
  display: flex;
  align-items: center;
  gap: 28px;
}

.avatar-glow-wrapper {
  padding: 4px;
  border-radius: 50%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.25), rgba(255, 255, 255, 0.02) 40%, transparent 60%);
  border: 1px solid var(--lg-border);
  box-shadow: 0 12px 36px rgba(0, 0, 0, 0.3);
}

.profile-avatar {
  width: 110px;
  height: 110px;
  border: 2px solid #04060d;
}

.user-text-details {
  display: flex;
  flex-direction: column;
}

.user-display-name {
  font-size: 26px;
  font-weight: 800;
  margin: 0;
  letter-spacing: -0.5px;
  background: linear-gradient(90deg, #fff, rgba(255, 255, 255, 0.8));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.user-unique-id {
  font-size: 14px;
  color: var(--lg-text-secondary);
  font-weight: 600;
  margin-bottom: 16px;
}

.user-action-buttons {
  display: flex;
  gap: 12px;
}

.btn {
  height: 38px;
  padding: 0 16px;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  transition: all var(--lg-motion);
  border: 1px solid var(--lg-border);
}

.btn-primary {
  background: var(--lg-brand-gradient);
  color: #fff;
  border-color: rgba(255, 255, 255, 0.2);
  box-shadow: 0 6px 16px rgba(255, 45, 120, 0.22);
}

.btn-primary:hover {
  filter: brightness(1.15);
  transform: translateY(-1px);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.08);
  color: var(--lg-text-primary);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.1);
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.16);
  border-color: rgba(255, 255, 255, 0.28);
}

/* User Stats */
.user-stats-bar {
  display: flex;
  gap: 36px;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  padding: 14px 0;
}

.stat-item {
  display: flex;
  align-items: baseline;
  gap: 6px;
}

.stat-value {
  font-size: 17px;
  font-weight: 800;
  color: var(--lg-text-primary);
}

.stat-label {
  font-size: 13px;
  color: var(--lg-text-secondary);
}

.user-bio {
  font-size: 14px;
  color: var(--lg-text-secondary);
  line-height: 1.5;
  margin: 0;
}

/* Tabs styles */
.profile-tabs-wrapper {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.glass-tabs-nav {
  display: flex;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--lg-border);
  padding: 4px;
  border-radius: 16px;
  width: fit-content;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.05);
}

.tab-nav-item {
  padding: 8px 24px;
  border-radius: 12px;
  color: var(--lg-text-secondary);
  font-weight: 700;
  font-size: 14px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all var(--lg-motion);
}

.tab-nav-item:hover {
  color: var(--lg-text-primary);
  background: rgba(255, 255, 255, 0.04);
}

.tab-nav-item.active {
  color: var(--lg-text-primary);
  background: rgba(255, 255, 255, 0.11);
  box-shadow: 
    inset 0 1px 0 rgba(255, 255, 255, 0.18),
    0 4px 12px rgba(0, 0, 0, 0.2);
}

.lock-icon {
  font-size: 13px;
}

/* Grid & Cards Container */
.video-grid-container {
  min-height: 200px;
}

.empty-videos {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
  color: var(--lg-text-muted);
  gap: 12px;
}

.empty-icon {
  font-size: 38px;
  opacity: 0.65;
}

.video-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.video-grid-card {
  aspect-ratio: 3 / 4;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid var(--lg-border);
  border-radius: 16px;
  overflow: hidden;
  position: relative;
  cursor: pointer;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.22);
  transition: all var(--lg-motion);
  transform-style: preserve-3d;
  perspective: 1000px;
}

.video-preview-wrapper {
  width: 100%;
  height: 100%;
  position: relative;
}

.preview-video-el {
  width: 100%;
  height: 100%;
  object-fit: cover;
  position: absolute;
  inset: 0;
  z-index: 0;
  opacity: 0;
  transition: opacity 0.25s ease-in-out;
}

.cover-image {
  width: 100%;
  height: 100%;
  background-size: cover;
  background-position: center;
  position: absolute;
  inset: 0;
  z-index: 1;
  transition: opacity 0.2s ease-in-out;
}

/* Hover preview play logic */
.video-grid-card:hover .preview-video-el {
  opacity: 1;
  z-index: 1;
}

.video-grid-card:hover .cover-image {
  opacity: 0;
}

/* Dynamic Glow card effect on hover */
.card-glow-overlay {
  position: absolute;
  inset: 0;
  z-index: 2;
  border-radius: inherit;
  border: 1px solid transparent;
  pointer-events: none;
  transition: all var(--lg-motion);
}

.video-grid-card:hover {
  transform: translateY(-4px) scale(1.02);
  box-shadow: 
    0 16px 36px rgba(0, 0, 0, 0.42),
    0 0 20px rgba(102, 217, 255, 0.22);
  border-color: var(--lg-border-strong);
}

.video-grid-card:hover .card-glow-overlay {
  border-color: rgba(102, 217, 255, 0.42);
  box-shadow: inset 0 0 12px rgba(102, 217, 255, 0.18);
}

/* Card details stats */
.card-stats-row {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  padding: 12px 14px;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.7) 0%, transparent 100%);
  display: flex;
  align-items: center;
  z-index: 3;
  pointer-events: none;
  opacity: 0.9;
  transition: opacity var(--lg-motion);
}

.video-grid-card:hover .card-stats-row {
  opacity: 1;
}

.card-likes {
  font-size: 13px;
  font-weight: 700;
  color: #fff;
  display: flex;
  align-items: center;
  gap: 5px;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.6);
}

.heart-icon {
  color: #ff2d78;
}

/* Fullscreen Video Playback Overlay */
.video-player-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
}

.video-player-overlay .backdrop {
  position: absolute;
  inset: 0;
  background: rgba(4, 5, 10, 0.7);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  z-index: 0;
}

.video-player-overlay .player-container {
  width: 100%;
  max-width: 580px;
  aspect-ratio: 9 / 16;
  max-height: 85vh;
  position: relative;
  z-index: 10;
  border: 1px solid var(--lg-border-strong);
  border-radius: 24px;
  box-shadow: 0 30px 70px rgba(0, 0, 0, 0.55);
  overflow: hidden;
}

.player-content-wrapper {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100%;
}

.player-header {
  padding: 16px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(4, 5, 10, 0.4);
}

.player-title {
  font-weight: 700;
  font-size: 15px;
  color: #fff;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 80%;
}

.player-header .close-btn {
  background: rgba(255, 255, 255, 0.07);
  border: none;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all var(--lg-motion);
}

.player-header .close-btn:hover {
  background: rgba(255, 255, 255, 0.18);
  transform: scale(1.05);
}

.player-video-box {
  flex: 1;
  background: #000;
  min-height: 0;
}

.main-video-player {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.player-info-footer {
  padding: 16px 20px;
  background: rgba(4, 5, 10, 0.65);
  border-top: 1px solid rgba(255, 255, 255, 0.06);
}

.author-tag {
  font-size: 14px;
  font-weight: 800;
  color: var(--lg-brand-cyan);
}

.player-info-footer .desc {
  font-size: 13px;
  color: var(--lg-text-secondary);
  margin-top: 4px;
  margin-bottom: 0;
}

/* Responsiveness overrides */
@media (max-width: 720px) {
  .profile-page-container {
    padding: 0 0 60px; /* remove padding, leave room for bottom nav */
    max-width: 100%;
  }

  .mobile-top-bar {
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    height: 52px;
    background: rgba(8, 10, 16, 0.5);
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    backdrop-filter: blur(10px);
    z-index: 10;
  }

  .back-btn {
    position: absolute;
    left: 12px;
    background: transparent;
    border: none;
    color: var(--lg-text-primary);
    font-size: 18px;
    cursor: pointer;
  }

  .user-handle {
    font-weight: 700;
    font-size: 15px;
  }

  .profile-scroll-content {
    padding: 12px;
  }

  .user-info-panel {
    padding: 20px;
    gap: 16px;
  }

  .user-main-row {
    gap: 16px;
  }

  .profile-avatar {
    width: 76px;
    height: 76px;
  }

  .user-display-name {
    font-size: 20px;
  }

  .user-action-buttons {
    flex-wrap: wrap;
    gap: 8px;
  }

  .btn {
    height: 32px;
    padding: 0 12px;
    font-size: 12px;
  }

  .user-stats-bar {
    gap: 20px;
    padding: 10px 0;
  }

  .stat-value {
    font-size: 15px;
  }

  .stat-label {
    font-size: 12px;
  }

  .video-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 4px;
  }

  .video-grid-card {
    border-radius: 8px;
  }

  .card-stats-row {
    padding: 6px 8px;
  }

  .card-likes {
    font-size: 11px;
  }

  .video-player-overlay .player-container {
    max-height: 80vh;
    max-width: 92%;
    border-radius: 18px;
  }
}
</style>
