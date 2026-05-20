<template>
  <div class="comment-drawer-wrapper" :class="{ 'is-open': open }">
    <!-- Overlay for mobile/tablet to close on backdrop click -->
    <div class="backdrop" @click="closeDrawer"></div>

    <div class="drawer-container">
      <LiquidGlass :opacity="0.14" :blur="'24px'" :distortion="true" borderRadius="0px">
        <div class="drawer-content">
          <!-- Drawer Header -->
          <div class="drawer-header">
            <span class="drawer-title">Comments ({{ totalCommentsCount }})</span>
            <button class="close-btn" @click="closeDrawer">
              <CloseOutlined />
            </button>
          </div>

          <!-- Comments List Area -->
          <div class="comments-scroll-area">
            <div v-if="comments.length === 0" class="empty-comments">
              <SmileOutlined class="empty-icon" />
              <p>Be the first to share your thoughts!</p>
            </div>
            
            <div v-else class="comment-list">
              <div v-for="comment in comments" :key="comment.id" class="comment-item">
                <div class="comment-avatar-container">
                  <a-avatar :src="comment.avatar" size="small" class="avatar" />
                </div>
                <div class="comment-main-body">
                  <div class="comment-author-name">@{{ comment.author }}</div>
                  <div class="comment-text-content">{{ comment.text }}</div>
                  <div class="comment-meta-info">
                    <span class="comment-time">{{ comment.time }}</span>
                    <span v-if="comment.replies && comment.replies.length > 0" class="reply-trigger" @click="toggleReplies(comment)">
                      {{ comment.showReplies ? 'Hide replies' : `View ${comment.replies.length} replies` }}
                    </span>
                  </div>

                  <!-- Nested Replies -->
                  <div v-if="comment.showReplies && comment.replies && comment.replies.length > 0" class="replies-container">
                    <div v-for="reply in comment.replies" :key="reply.id" class="reply-item">
                      <div class="reply-avatar-container">
                        <a-avatar :src="reply.avatar" :size="20" class="avatar" />
                      </div>
                      <div class="reply-main-body">
                        <div class="reply-author-name">@{{ reply.author }}</div>
                        <div class="reply-text-content">{{ reply.text }}</div>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="comment-actions">
                  <button class="comment-like-btn" :class="{ 'is-liked': comment.liked }" @click="toggleLike(comment)">
                    <component :is="comment.liked ? HeartFilled : HeartOutlined" />
                  </button>
                  <span class="comment-likes-count">{{ formatNumber(comment.likes) }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Drawer Footer - Send Comment -->
          <div class="drawer-footer glass-input-area">
            <div class="input-wrapper">
              <input 
                type="text" 
                v-model="newCommentText" 
                placeholder="Add a comment..." 
                @keyup.enter="sendComment" 
              />
              <button class="emoji-btn" @click="triggerEmoji">
                <SmileOutlined />
              </button>
              <button class="send-btn" :disabled="!newCommentText.trim()" @click="sendComment">
                <SendOutlined />
              </button>
            </div>
          </div>
        </div>
      </LiquidGlass>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import { CloseOutlined, HeartOutlined, HeartFilled, SendOutlined, SmileOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import LiquidGlass from '@/components/common/LiquidGlass.vue';

const props = defineProps({
  open: { type: Boolean, required: true },
  videoId: { type: String, default: '' },
  commentsCount: { type: Number, default: 0 }
});

const emit = defineEmits(['update:open', 'comment-added']);

const newCommentText = ref('');
const comments = ref([]);

// Setup mock comment templates based on video
const mockCommentsDb = {
  'V001': [
    {
      id: 1,
      avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Emma',
      author: 'emma_nature',
      text: 'Wow! This forest stream look is absolutely stunning. I can literally feel the sunlight through my screen! 🌞🍃',
      time: '1 hour ago',
      likes: 580,
      liked: false,
      replies: [
        { id: 11, avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Lucas', author: 'lucas_cam', text: 'Same! The color grading here is spectacular.' }
      ],
      showReplies: false
    },
    {
      id: 2,
      avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Oliver',
      author: 'oliver_woods',
      text: 'Nature always has the best screen savers. Outstanding resolution!',
      time: '4 hours ago',
      likes: 120,
      liked: true,
      replies: [],
      showReplies: false
    }
  ],
  'V002': [
    {
      id: 1,
      avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Sophia',
      author: 'sophia_cat',
      text: 'Oh my goodness, those little paws! I cannot stop watching this cat. Absolutely adorable! 🐾😻',
      time: '30 minutes ago',
      likes: 1240,
      liked: false,
      replies: [
        { id: 21, avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Max', author: 'max_paws', text: 'Cutest video on the internet today, hands down!' },
        { id: 22, avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Sophia', author: 'sophia_cat', text: 'Agreed! Saved this to watch when I have a bad day.' }
      ],
      showReplies: false
    },
    {
      id: 2,
      avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Liam',
      author: 'liam_meme',
      text: 'Cats are liquid, confirmed. 😹',
      time: '2 hours ago',
      likes: 412,
      liked: false,
      replies: [],
      showReplies: false
    }
  ],
  'V003': [
    {
      id: 1,
      avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Jack',
      author: 'jack_codes',
      text: 'Vue 3 + Vite is such a game changer. The liquid glass component you built in the demo is incredibly fluid. Great tutorial!',
      time: '5 hours ago',
      likes: 342,
      liked: false,
      replies: [
        { id: 31, avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=Aiden', author: 'aiden_dev', text: 'Totally agree. Standard WebGL takes 10x more boilerplate.' }
      ],
      showReplies: false
    }
  ]
};

// Default comments when not matched
const defaultComments = [
  {
    id: 1,
    avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=User1',
    author: 'digital_creator',
    text: 'Amazing liquid glass effects! The visual responsiveness is very premium.',
    time: '2 days ago',
    likes: 85,
    liked: false,
    replies: [],
    showReplies: false
  }
];

// Load comments when videoId changes
watch(() => props.videoId, (newId) => {
  if (newId && mockCommentsDb[newId]) {
    comments.value = JSON.parse(JSON.stringify(mockCommentsDb[newId]));
  } else {
    comments.value = JSON.parse(JSON.stringify(defaultComments));
  }
}, { immediate: true });

const totalCommentsCount = computed(() => {
  let count = comments.value.length;
  comments.value.forEach(c => {
    if (c.replies) count += c.replies.length;
  });
  return count;
});

const closeDrawer = () => {
  emit('update:open', false);
};

const toggleLike = (comment) => {
  comment.liked = !comment.liked;
  if (comment.liked) {
    comment.likes += 1;
  } else {
    comment.likes -= 1;
  }
};

const toggleReplies = (comment) => {
  comment.showReplies = !comment.showReplies;
};

const sendComment = () => {
  if (!newCommentText.value.trim()) return;

  const newComment = {
    id: Date.now(),
    avatar: 'https://api.dicebear.com/7.x/notionists/svg?seed=User',
    author: 'aixcrimson',
    text: newCommentText.value,
    time: 'Just now',
    likes: 0,
    liked: false,
    replies: [],
    showReplies: false
  };

  comments.value.unshift(newComment);
  newCommentText.value = '';
  message.success('Comment posted!');
  
  // Sync back to feed
  emit('comment-added', totalCommentsCount.value);
};

const triggerEmoji = () => {
  const emojis = ['✨', '💖', '🔥', '😹', '🤩', '👍', '🌴', '🎨'];
  const randomEmoji = emojis[Math.floor(Math.random() * emojis.length)];
  newCommentText.value += randomEmoji;
};

const formatNumber = (num) => {
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K';
  }
  return num.toString();
};
</script>

<style scoped>
.comment-drawer-wrapper {
  position: absolute;
  top: 0;
  right: 0;
  width: 100%;
  height: 100%;
  z-index: 100;
  display: flex;
  justify-content: flex-end;
  pointer-events: none;
  overflow: hidden;
}

.backdrop {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.4);
  opacity: 0;
  transition: opacity 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
  pointer-events: none;
  z-index: 0;
}

.drawer-container {
  position: relative;
  width: 420px;
  height: 100%;
  transform: translateX(100%);
  transition: transform 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
  pointer-events: auto;
  z-index: 10;
  border-left: 1px solid var(--lg-border);
  box-shadow: -10px 0 40px rgba(0, 0, 0, 0.35);
}

.comment-drawer-wrapper.is-open {
  pointer-events: auto;
}

.comment-drawer-wrapper.is-open .backdrop {
  opacity: 1;
  pointer-events: auto;
}

.comment-drawer-wrapper.is-open .drawer-container {
  transform: translateX(0);
}

.drawer-content {
  display: flex;
  flex-direction: column;
  height: 100%;
  width: 100%;
}

/* Header styling */
.drawer-header {
  padding: 20px 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.drawer-title {
  font-size: 17px;
  font-weight: 700;
  color: var(--lg-text-primary);
  letter-spacing: -0.2px;
}

.close-btn {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.08);
  color: var(--lg-text-secondary);
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all var(--lg-motion);
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.15);
  color: var(--lg-text-primary);
  transform: rotate(90deg);
}

/* Comments Scroll Area */
.comments-scroll-area {
  flex: 1;
  overflow-y: auto;
  padding: 16px 20px;
  min-height: 0;
}

/* Scrollbar customization */
.comments-scroll-area::-webkit-scrollbar {
  width: 6px;
}

.comments-scroll-area::-webkit-scrollbar-track {
  background: transparent;
}

.comments-scroll-area::-webkit-scrollbar-thumb {
  background-color: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
}

.comments-scroll-area::-webkit-scrollbar-thumb:hover {
  background-color: rgba(255, 255, 255, 0.22);
}

.empty-comments {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: var(--lg-text-muted);
  gap: 12px;
}

.empty-icon {
  font-size: 40px;
  opacity: 0.6;
}

/* Comment Item layout */
.comment-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.comment-item {
  display: flex;
  gap: 12px;
  position: relative;
  align-items: flex-start;
}

.comment-avatar-container {
  flex-shrink: 0;
}

.comment-avatar-container .avatar {
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.comment-main-body {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.comment-author-name {
  font-size: 13px;
  font-weight: 700;
  color: var(--lg-text-primary);
}

.comment-text-content {
  font-size: 14px;
  color: var(--lg-text-secondary);
  line-height: 1.4;
  word-break: break-word;
}

.comment-meta-info {
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 12px;
  color: var(--lg-text-muted);
  margin-top: 2px;
}

.reply-trigger {
  color: var(--lg-brand-cyan);
  font-weight: 600;
  cursor: pointer;
}

.reply-trigger:hover {
  text-decoration: underline;
}

/* Nest replies container */
.replies-container {
  margin-top: 12px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-left: 8px;
  border-left: 2px solid rgba(255, 255, 255, 0.06);
}

.reply-item {
  display: flex;
  gap: 8px;
}

.reply-avatar-container {
  flex-shrink: 0;
}

.reply-main-body {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.reply-author-name {
  font-size: 12px;
  font-weight: 700;
  color: var(--lg-text-primary);
}

.reply-text-content {
  font-size: 13px;
  color: var(--lg-text-secondary);
  line-height: 1.35;
}

/* Comment actions (likes) */
.comment-actions {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  min-width: 28px;
}

.comment-like-btn {
  background: transparent;
  border: none;
  color: var(--lg-text-muted);
  font-size: 16px;
  cursor: pointer;
  padding: 4px;
  transition: all var(--lg-motion);
  display: flex;
  align-items: center;
  justify-content: center;
}

.comment-like-btn:hover {
  color: var(--lg-text-primary);
  transform: scale(1.15);
}

.comment-like-btn.is-liked {
  color: #ff2d78;
  filter: drop-shadow(0 0 4px rgba(255, 45, 120, 0.4));
  animation: heartPop 0.25s cubic-bezier(0.175, 0.885, 0.32, 1.3);
}

@keyframes heartPop {
  0% { transform: scale(1); }
  50% { transform: scale(1.35); }
  100% { transform: scale(1); }
}

.comment-likes-count {
  font-size: 11px;
  color: var(--lg-text-muted);
  font-weight: 500;
}

/* Bottom Send Input Box */
.glass-input-area {
  padding: 16px 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(14, 18, 30, 0.4);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
}

.input-wrapper {
  display: flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--lg-border);
  border-radius: 16px;
  padding: 2px 2px 2px 14px;
  height: 42px;
  transition: all var(--lg-motion);
}

.input-wrapper:focus-within {
  border-color: rgba(102, 217, 255, 0.5);
  background: rgba(255, 255, 255, 0.09);
  box-shadow: 0 0 14px rgba(102, 217, 255, 0.12);
}

.input-wrapper input {
  flex: 1;
  background: transparent;
  border: none;
  outline: none;
  color: var(--lg-text-primary);
  font-size: 14px;
}

.input-wrapper input::placeholder {
  color: var(--lg-text-muted);
}

.emoji-btn,
.send-btn {
  background: transparent;
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 16px;
  transition: all var(--lg-motion);
}

.emoji-btn {
  color: var(--lg-text-secondary);
}

.emoji-btn:hover {
  color: var(--lg-brand-cyan);
  background: rgba(255, 255, 255, 0.06);
}

.send-btn {
  color: var(--lg-brand-cyan);
}

.send-btn:disabled {
  color: var(--lg-text-muted);
  cursor: not-allowed;
}

.send-btn:not(:disabled):hover {
  background: var(--lg-brand-gradient);
  color: #fff;
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(255, 45, 120, 0.3);
}

/* Tablet & Mobile responsive drawers */
@media (max-width: 720px) {
  .comment-drawer-wrapper {
    justify-content: center;
    align-items: flex-end;
  }

  .drawer-container {
    width: 100%;
    height: 70vh;
    border-radius: 28px 28px 0 0;
    transform: translateY(100%);
    border-left: none;
    border-top: 1px solid var(--lg-border-strong);
    box-shadow: 0 -10px 40px rgba(0, 0, 0, 0.45);
    overflow: hidden;
  }

  .comment-drawer-wrapper.is-open .drawer-container {
    transform: translateY(0);
  }
}
</style>
