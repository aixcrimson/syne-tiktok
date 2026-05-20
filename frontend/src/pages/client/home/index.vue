<template>
  <div class="home-feed-container" @wheel="handleWheel" @keydown="handleKeyDown" tabindex="0" ref="feedRef">
    <!-- Blurry video cover background to give cinema aesthetic on PC -->
    <div 
      class="cinema-backdrop" 
      :style="{ backgroundImage: `url(${currentVideo.cover})` }"
    ></div>

    <div class="feed-main-area">
      <!-- Video Player Card Container -->
      <div 
        class="video-card-container"
        @touchstart="onTouchStart"
        @touchmove="onTouchMove"
        @touchend="onTouchEnd"
      >
        <!-- Double Click Heart Pops container -->
        <div class="heart-pops-layer" @click="handleSingleOrDoubleClick">
          <div 
            v-for="heart in heartPops" 
            :key="heart.id" 
            class="double-click-heart-pop"
            :style="{ top: `${heart.y}px`, left: `${heart.x}px` }"
          >
            <HeartFilled />
          </div>
        </div>

        <video
          ref="videoPlayerRef"
          :src="currentVideo.videoUrl"
          loop
          playsinline
          class="feed-video-player"
          @click="togglePlay"
        ></video>

        <!-- Pause overlay button if paused -->
        <div v-if="isPaused" class="play-state-overlay" @click="togglePlay">
          <div class="play-icon-circle">
            <PlayCircleFilled />
          </div>
        </div>

        <!-- Video Bottom Metadata Details (Overlay) -->
        <div class="video-meta-overlay">
          <div class="meta-info-card">
            <div class="author-row" @click="goToAuthor(currentVideo.author)">
              <span class="author-name">@{{ currentVideo.author }}</span>
            </div>
            
            <p class="description">{{ currentVideo.description }}</p>
            
            <div class="music-row">
              <CustomerServiceOutlined class="music-icon" />
              <div class="music-text-container">
                <span class="music-text">{{ currentVideo.music }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Video Right Action Column (Overlay) -->
        <div class="video-actions-overlay">
          <!-- Profile avatar + Follow btn -->
          <div class="action-item avatar-item">
            <div class="avatar-ring" @click="goToAuthor(currentVideo.author)">
              <a-avatar :src="currentVideo.id === 'uploaded' ? 'https://api.dicebear.com/7.x/notionists/svg?seed=User' : `https://api.dicebear.com/7.x/notionists/svg?seed=${currentVideo.author}`" />
            </div>
            <button 
              v-if="!currentVideo.followed" 
              class="follow-btn" 
              @click.stop="toggleFollow"
            >
              <PlusOutlined />
            </button>
            <button 
              v-else 
              class="follow-btn followed" 
              @click.stop="toggleFollow"
            >
              <CheckOutlined />
            </button>
          </div>

          <!-- Like action -->
          <div class="action-item" @click="toggleLike">
            <div class="action-btn-circle" :class="{ 'liked': currentVideo.liked }">
              <component :is="currentVideo.liked ? HeartFilled : HeartOutlined" />
            </div>
            <span class="action-label">{{ formatNumber(currentVideo.likes) }}</span>
          </div>

          <!-- Comment action -->
          <div class="action-item" @click="openComments">
            <div class="action-btn-circle">
              <MessageFilled />
            </div>
            <span class="action-label">{{ formatNumber(currentVideo.comments) }}</span>
          </div>

          <!-- Favorite action -->
          <div class="action-item" @click="toggleFavorite">
            <div class="action-btn-circle" :class="{ 'favorited': currentVideo.favorited }">
              <component :is="currentVideo.favorited ? StarFilled : StarOutlined" />
            </div>
            <span class="action-label">Favorite</span>
          </div>

          <!-- Share action -->
          <div class="action-item" @click="shareVideo">
            <div class="action-btn-circle">
              <ShareAltOutlined />
            </div>
            <span class="action-label">Share</span>
          </div>

          <!-- Spinning Vinyl record for music -->
          <div class="action-item vinyl-item">
            <div class="vinyl-record" :class="{ 'playing': !isPaused }">
              <div class="vinyl-center"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Video Feed indicators on PC -->
      <div class="feed-scroll-bullets">
        <div 
          v-for="(vid, index) in videos" 
          :key="vid.id" 
          class="bullet" 
          :class="{ 'active': index === activeIndex }"
          @click="jumpToVideo(index)"
        ></div>
      </div>
    </div>

    <!-- Integrated Comment Drawer -->
    <CommentDrawer 
      v-model:open="isCommentOpen" 
      :videoId="currentVideo.id"
      :commentsCount="currentVideo.comments"
      @comment-added="handleCommentAdded"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { 
  HeartFilled, 
  HeartOutlined, 
  MessageFilled, 
  StarFilled, 
  StarOutlined, 
  ShareAltOutlined, 
  PlusOutlined, 
  CheckOutlined, 
  CustomerServiceOutlined
} from '@ant-design/icons-vue';
import { PlayCircleFilled } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import CommentDrawer from '../components/CommentDrawer.vue';

const router = useRouter();

const feedRef = ref(null);
const videoPlayerRef = ref(null);
const activeIndex = ref(0);
const isPaused = ref(false);
const isCommentOpen = ref(false);

const heartPops = ref([]);

// Default TikTok Videos
const defaultFeedVideos = [
  {
    id: 'V001',
    cover: 'https://picsum.photos/id/10/200/300',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-forest-stream-in-the-sunlight-529-large.mp4',
    description: 'Fresh forest stream in the morning sunlight. Nature heals! 🌲☀️ #nature #relax #view',
    author: 'nature_lover',
    music: 'Original Sound - nature_lover',
    likes: 58200,
    comments: 11,
    shares: 4200,
    liked: false,
    favorited: false,
    followed: false
  },
  {
    id: 'V002',
    cover: 'https://picsum.photos/id/20/200/300',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-playful-cat-lying-on-a-carpet-43286-large.mp4',
    description: 'Look at those paws! He is just looking for attention. 🐾😻 #cats #funny #cute',
    author: 'cat_memes',
    music: 'Cute Cat Instrumental - Lofi Beats',
    likes: 231400,
    comments: 24,
    shares: 8900,
    liked: true,
    favorited: true,
    followed: true
  },
  {
    id: 'V003',
    cover: 'https://picsum.photos/id/30/200/300',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-typing-on-a-backlit-keyboard-in-the-dark-44026-large.mp4',
    description: 'Building custom Liquid Glass elements in Vue 3 has never been easier! Let me show you how. 💻✨ #vuejs #javascript #coding',
    author: 'dev_guru',
    music: 'Cyberpunk Synthwave - Developer Tune',
    likes: 45300,
    comments: 1,
    shares: 1200,
    liked: false,
    favorited: false,
    followed: false
  },
  {
    id: 'V004',
    cover: 'https://picsum.photos/id/40/200/300',
    videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-cutting-vegetables-on-a-wooden-board-43026-large.mp4',
    description: 'Fast knife cooking skill. Dinner starts here! 🔪🌶️ #foodie #cooking #streetfood',
    author: 'food_vlog',
    music: 'Acoustic Folk Cooking Beats - Chef',
    likes: 9100,
    comments: 0,
    shares: 310,
    liked: false,
    favorited: false,
    followed: false
  }
];

const videos = ref([...defaultFeedVideos]);

const currentVideo = computed(() => {
  return videos.value[activeIndex.value] || defaultFeedVideos[0];
});

onMounted(() => {
  // Focus feed to capture keyboard inputs
  if (feedRef.value) {
    feedRef.value.focus();
  }

  // Play video on mount
  playCurrentVideo();

  // Listen to search keywords
  window.addEventListener('feed-search', (e) => {
    const keyword = e.detail.toLowerCase();
    const foundIndex = videos.value.findIndex(v => 
      v.description.toLowerCase().includes(keyword) || 
      v.author.toLowerCase().includes(keyword)
    );
    if (foundIndex !== -1) {
      jumpToVideo(foundIndex);
    } else {
      message.warn('No matching video found.');
    }
  });

  // Listen to newly published videos from Layout
  window.addEventListener('video-published', (e) => {
    if (e.detail) {
      const newVideoItem = {
        ...e.detail,
        id: 'uploaded', // tag it
        likes: 0,
        comments: 0,
        shares: 0,
        liked: false,
        favorited: false,
        followed: false,
        music: `Original Sound - ${e.detail.author}`
      };
      videos.value.unshift(newVideoItem);
      // jump to first video automatically
      jumpToVideo(0);
    }
  });
});

onUnmounted(() => {
  stopCurrentVideo();
});

const playCurrentVideo = () => {
  isPaused.value = false;
  setTimeout(() => {
    if (videoPlayerRef.value) {
      videoPlayerRef.value.play().catch(() => {
        // Handle browser autoplay restriction policies
        isPaused.value = true;
      });
    }
  }, 100);
};

const stopCurrentVideo = () => {
  if (videoPlayerRef.value) {
    videoPlayerRef.value.pause();
  }
};

const togglePlay = () => {
  if (!videoPlayerRef.value) return;
  if (videoPlayerRef.value.paused) {
    videoPlayerRef.value.play();
    isPaused.value = false;
  } else {
    videoPlayerRef.value.pause();
    isPaused.value = true;
  }
};

// Double Click to Like or Single Click to Play/Pause logic
let lastClickTime = 0;
const handleSingleOrDoubleClick = (e) => {
  const currentTime = Date.now();
  const timeDiff = currentTime - lastClickTime;
  
  if (timeDiff < 280) {
    // Double click
    handleDoubleClick(e);
  } else {
    // Single click (wait to check if it's double)
    setTimeout(() => {
      // If no other click happened, trigger play/pause
      if (lastClickTime === currentTime) {
        togglePlay();
      }
    }, 280);
  }
  
  lastClickTime = currentTime;
};

const handleDoubleClick = (e) => {
  // Get relative click coordinate to video container
  const rect = e.currentTarget.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;

  // Add a double click heart popup item
  const id = Date.now();
  heartPops.value.push({ id, x, y });

  // Make like state active
  if (!currentVideo.value.liked) {
    currentVideo.value.liked = true;
    currentVideo.value.likes += 1;
  }

  // Remove heart element after animation completes
  setTimeout(() => {
    heartPops.value = heartPops.value.filter(h => h.id !== id);
  }, 800);
};

// Wheel (Mouse scroll) throttle
let lastScrollTime = 0;
const handleWheel = (e) => {
  const now = Date.now();
  if (now - lastScrollTime < 700) return; // 700ms throttle cooldown

  if (e.deltaY > 15) {
    // Scroll Down
    scrollNext();
    lastScrollTime = now;
  } else if (e.deltaY < -15) {
    // Scroll Up
    scrollPrev();
    lastScrollTime = now;
  }
};

const handleKeyDown = (e) => {
  if (e.key === 'ArrowDown') {
    scrollNext();
  } else if (e.key === 'ArrowUp') {
    scrollPrev();
  } else if (e.key === ' ') {
    e.preventDefault();
    togglePlay();
  }
};

// Touch gestures for mobile
let touchStartY = 0;
let touchEndY = 0;

const onTouchStart = (e) => {
  touchStartY = e.touches[0].clientY;
};

const onTouchMove = (e) => {
  touchEndY = e.touches[0].clientY;
};

const onTouchEnd = () => {
  const dragDist = touchStartY - touchEndY;
  if (dragDist > 50) {
    scrollNext();
  } else if (dragDist < -50) {
    scrollPrev();
  }
};

const scrollNext = () => {
  if (activeIndex.value < videos.value.length - 1) {
    activeIndex.value += 1;
    playCurrentVideo();
  } else {
    message.info('You reached the end of the feed!');
  }
};

const scrollPrev = () => {
  if (activeIndex.value > 0) {
    activeIndex.value -= 1;
    playCurrentVideo();
  }
};

const jumpToVideo = (index) => {
  activeIndex.value = index;
  playCurrentVideo();
};

const goToAuthor = (author) => {
  router.push(`/user/${author}`);
};

const toggleFollow = () => {
  currentVideo.value.followed = !currentVideo.value.followed;
  if (currentVideo.value.followed) {
    message.success(`Followed @${currentVideo.value.author}`);
  }
};

const toggleLike = () => {
  currentVideo.value.liked = !currentVideo.value.liked;
  if (currentVideo.value.liked) {
    currentVideo.value.likes += 1;
  } else {
    currentVideo.value.likes -= 1;
  }
};

const openComments = () => {
  isCommentOpen.value = true;
};

const handleCommentAdded = (newCount) => {
  currentVideo.value.comments = newCount;
};

const toggleFavorite = () => {
  currentVideo.value.favorited = !currentVideo.value.favorited;
  if (currentVideo.value.favorited) {
    message.success('Added to favorites!');
  }
};

const shareVideo = () => {
  message.success('Copied video link to clipboard!');
};

const formatNumber = (num) => {
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K';
  }
  return num.toString();
};
</script>

<style scoped>
.home-feed-container {
  display: flex;
  flex: 1;
  width: 100%;
  height: 100%;
  position: relative;
  overflow: hidden;
  outline: none;
}

/* Background cinema cover effect */
.cinema-backdrop {
  position: absolute;
  inset: -20px;
  background-size: cover;
  background-position: center;
  filter: blur(48px) brightness(0.24) saturate(0.8);
  z-index: 0;
  pointer-events: none;
  opacity: 0.85;
  transition: background-image 0.5s ease-in-out;
}

.feed-main-area {
  display: flex;
  justify-content: center;
  align-items: center;
  flex: 1;
  z-index: 10;
  height: 100%;
  position: relative;
}

/* Central Video Card Container (9:16) */
.video-card-container {
  width: 100%;
  max-width: 440px;
  height: 92%;
  max-height: 780px;
  background: #000;
  border-radius: 24px;
  border: 1px solid var(--lg-border-strong);
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.6), 0 0 40px rgba(102, 217, 255, 0.1);
  overflow: hidden;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.feed-video-player {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* Hearts double click pop section */
.heart-pops-layer {
  position: absolute;
  inset: 0;
  z-index: 12;
  cursor: pointer;
}

.double-click-heart-pop {
  position: absolute;
  transform: translate(-50%, -50%);
  color: #ff2d78;
  font-size: 80px;
  filter: drop-shadow(0 0 16px rgba(255, 45, 120, 0.8));
  pointer-events: none;
  animation: heartPopAnim 0.8s cubic-bezier(0.175, 0.885, 0.32, 1.4) forwards;
}

@keyframes heartPopAnim {
  0% { transform: translate(-50%, -50%) scale(0.3) rotate(-15deg); opacity: 0; }
  25% { transform: translate(-50%, -50%) scale(1.1) rotate(10deg); opacity: 1; }
  60% { transform: translate(-50%, -50%) scale(1) rotate(0deg); opacity: 0.8; }
  100% { transform: translate(-50%, -50%) scale(0.7) translateY(-80px) rotate(-10deg); opacity: 0; }
}

/* Play state overlay overlay */
.play-state-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 11;
  pointer-events: none;
}

.play-icon-circle {
  font-size: 72px;
  color: rgba(255, 255, 255, 0.82);
  filter: drop-shadow(0 4px 16px rgba(0, 0, 0, 0.4));
  animation: playPop 0.3s cubic-bezier(0.25, 0.8, 0.25, 1.2);
}

@keyframes playPop {
  0% { transform: scale(0.5); opacity: 0; }
  100% { transform: scale(1); opacity: 1; }
}

/* Video details bottom metadata styling */
.video-meta-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  padding: 40px 18px 20px;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.85) 0%, rgba(0, 0, 0, 0.4) 60%, transparent 100%);
  z-index: 15;
  pointer-events: none;
}

.meta-info-card {
  display: flex;
  flex-direction: column;
  gap: 8px;
  pointer-events: auto;
}

.author-row {
  cursor: pointer;
  width: fit-content;
}

.author-name {
  font-size: 16px;
  font-weight: 800;
  color: #fff;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.8);
}

.author-name:hover {
  text-decoration: underline;
  color: var(--lg-brand-cyan);
}

.description {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.45;
  margin: 0;
  word-break: break-word;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.8);
}

.music-row {
  display: flex;
  align-items: center;
  gap: 8px;
  color: rgba(255, 255, 255, 0.85);
  font-size: 13px;
  margin-top: 4px;
}

.music-icon {
  font-size: 14px;
}

.music-text-container {
  overflow: hidden;
  white-space: nowrap;
  width: 180px;
  position: relative;
}

.music-text {
  display: inline-block;
  padding-left: 100%;
  animation: marquee 8s linear infinite;
  font-weight: 500;
}

@keyframes marquee {
  0% { transform: translate3d(0, 0, 0); }
  100% { transform: translate3d(-100%, 0, 0); }
}

/* Video Right Action Column Overlay */
.video-actions-overlay {
  position: absolute;
  right: 12px;
  bottom: 80px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 18px;
  z-index: 15;
}

.action-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  cursor: pointer;
}

.action-btn-circle {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid var(--lg-border);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.15);
  transition: all var(--lg-motion);
}

.action-btn-circle:hover {
  background: rgba(255, 255, 255, 0.18);
  transform: scale(1.1);
}

.action-btn-circle:active {
  transform: scale(0.9);
}

.action-btn-circle.liked {
  color: #ff2d78;
  border-color: rgba(255, 45, 120, 0.42);
  filter: drop-shadow(0 0 6px rgba(255, 45, 120, 0.5));
}

.action-btn-circle.favorited {
  color: #ffb700;
  border-color: rgba(255, 183, 0, 0.42);
  filter: drop-shadow(0 0 6px rgba(255, 183, 0, 0.4));
}

.action-label {
  font-size: 11px;
  font-weight: 700;
  color: rgba(255, 255, 255, 0.9);
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.8);
}

/* Avatar element custom follow button */
.avatar-item {
  position: relative;
  margin-bottom: 8px;
}

.avatar-ring {
  padding: 2.5px;
  border-radius: 50%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.3), transparent);
  border: 1px solid var(--lg-border);
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--lg-motion);
}

.avatar-ring:hover {
  transform: scale(1.05);
  background: var(--lg-brand-gradient);
}

.follow-btn {
  position: absolute;
  bottom: -4px;
  left: 50%;
  transform: translateX(-50%) scale(1);
  background: #ff2d78;
  border: 1.5px solid #000;
  color: #fff;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  cursor: pointer;
  box-shadow: 0 2px 6px rgba(255, 45, 120, 0.4);
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.3);
}

.follow-btn:hover {
  transform: translateX(-50%) scale(1.18);
  background: #ff3a84;
}

.follow-btn.followed {
  background: #22d399;
  box-shadow: 0 2px 6px rgba(34, 211, 153, 0.4);
  transform: translateX(-50%) scale(0.9) rotate(360deg);
}

/* Vinyl Spinning record */
.vinyl-item {
  margin-top: 4px;
}

.vinyl-record {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  background: radial-gradient(circle, #333 30%, #111 60%, #000 100%);
  border: 1.5px solid rgba(255, 255, 255, 0.28);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.vinyl-record.playing {
  animation: spin VinylSpin 3.5s linear infinite;
}

@keyframes VinylSpin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.vinyl-center {
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: var(--lg-brand-gradient);
  border: 1px solid #111;
}

/* Bullet markers indicators on PC screen */
.feed-scroll-bullets {
  position: absolute;
  right: 40px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.bullet {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.22);
  cursor: pointer;
  transition: all var(--lg-motion);
  border: 1px solid transparent;
}

.bullet:hover {
  background: rgba(255, 255, 255, 0.6);
}

.bullet.active {
  background: var(--lg-brand-cyan);
  transform: scale(1.4);
  box-shadow: 0 0 10px rgba(102, 217, 255, 0.8);
  border-color: rgba(255, 255, 255, 0.2);
}

/* Desktop and general screen responsive layout */
@media (max-width: 720px) {
  .feed-scroll-bullets {
    display: none;
  }

  .video-card-container {
    max-width: 100%;
    height: 100%;
    max-height: 100vh;
    border-radius: 0;
    border: none;
    box-shadow: none;
  }

  .feed-main-area {
    height: 100%;
  }

  .cinema-backdrop {
    display: none;
  }

  .video-actions-overlay {
    right: 10px;
    bottom: 24px;
  }

  .video-meta-overlay {
    padding-bottom: 24px;
  }
}
</style>
