<template>
  <div class="upload-modal-wrapper" v-if="open">
    <div class="modal-backdrop" @click="closeModal"></div>
    
    <div class="modal-container">
      <LiquidGlass :opacity="0.14" :blur="'30px'" :distortion="true" borderRadius="28px">
        <div class="modal-content">
          <!-- Modal Header -->
          <div class="modal-header">
            <span class="modal-title">Upload Video</span>
            <button class="close-btn" @click="closeModal">
              <CloseOutlined />
            </button>
          </div>

          <!-- Modal Body -->
          <div class="modal-body">
            <!-- Left Side: Dropzone -->
            <div class="upload-dropzone-section">
              <div 
                v-if="!fileSelected" 
                class="dropzone-box"
                :class="{ 'dragging': isDragging }"
                @dragover.prevent="onDragOver"
                @dragleave.prevent="onDragLeave"
                @drop.prevent="onDrop"
                @click="triggerFileSelect"
              >
                <input 
                  type="file" 
                  ref="fileInputRef" 
                  accept="video/*" 
                  style="display: none" 
                  @change="onFileChange" 
                />
                <CloudUploadOutlined class="upload-icon" />
                <span class="upload-title">Select video to upload</span>
                <span class="upload-subtitle">Or drag and drop a file here</span>
                <span class="upload-hint">MP4 or WebM • 720x1280 or higher • Up to 100 MB</span>
              </div>

              <!-- Uploading / Finished State -->
              <div v-else class="upload-progress-box">
                <div class="video-preview-placeholder">
                  <div class="cover-glow-back" :style="{ backgroundImage: `url(${selectedCover})` }"></div>
                  <div class="cover-card" :style="{ backgroundImage: `url(${selectedCover})` }"></div>
                  <span class="file-name">{{ fileName }}</span>
                </div>

                <!-- Liquid Wave Progress Bar -->
                <div class="liquid-progress-container">
                  <div class="progress-bar-rail">
                    <div class="progress-fill" :style="{ width: `${uploadProgress}%` }">
                      <!-- Wave effect inside the progress fill -->
                      <div class="wave wave-1"></div>
                      <div class="wave wave-2"></div>
                    </div>
                  </div>
                  <div class="progress-text-row">
                    <span v-if="uploadProgress < 100">Uploading... {{ uploadProgress }}%</span>
                    <span v-else class="upload-success-text">
                      <CheckCircleFilled /> Upload Complete
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Right Side: Form details -->
            <div class="upload-details-section">
              <div class="form-item">
                <label>Title</label>
                <input 
                  type="text" 
                  v-model="videoTitle" 
                  placeholder="Give your video a catchy title..." 
                  maxLength="80" 
                />
              </div>

              <div class="form-item">
                <label>Description</label>
                <textarea 
                  v-model="videoDesc" 
                  placeholder="What is this video about? Add tags #nature #vlog #creative..." 
                  rows="4"
                  maxLength="200"
                ></textarea>
              </div>

              <div class="form-item">
                <label>Select Cover Template</label>
                <div class="cover-selection-grid">
                  <div 
                    v-for="(cover, idx) in availableCovers" 
                    :key="idx" 
                    class="cover-option-card"
                    :class="{ 'active': selectedCover === cover }"
                    :style="{ backgroundImage: `url(${cover})` }"
                    @click="selectedCover = cover"
                  >
                    <div class="selected-overlay" v-if="selectedCover === cover">
                      <CheckCircleFilled />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Modal Footer -->
          <div class="modal-footer">
            <button class="cancel-btn" @click="closeModal">Cancel</button>
            <button 
              class="publish-btn" 
              :disabled="!isPublishReady" 
              @click="publishVideo"
            >
              Publish
            </button>
          </div>
        </div>
      </LiquidGlass>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { CloudUploadOutlined, CloseOutlined, CheckCircleFilled } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import LiquidGlass from '@/components/common/LiquidGlass.vue';

const props = defineProps({
  open: { type: Boolean, required: true }
});

const emit = defineEmits(['update:open', 'uploaded']);

const fileInputRef = ref(null);
const fileSelected = ref(false);
const fileName = ref('');
const isDragging = ref(false);
const uploadProgress = ref(0);

const videoTitle = ref('');
const videoDesc = ref('');

// Pre-defined random beautiful cover choices
const availableCovers = [
  'https://picsum.photos/id/10/200/300',
  'https://picsum.photos/id/20/200/300',
  'https://picsum.photos/id/30/200/300',
  'https://picsum.photos/id/40/200/300',
  'https://picsum.photos/id/50/200/300'
];
const selectedCover = ref(availableCovers[0]);

const isPublishReady = computed(() => {
  return fileSelected.value && uploadProgress.value === 100 && videoTitle.value.trim();
});

const closeModal = () => {
  resetForm();
  emit('update:open', false);
};

const resetForm = () => {
  fileSelected.value = false;
  fileName.value = '';
  uploadProgress.value = 0;
  videoTitle.value = '';
  videoDesc.value = '';
  selectedCover.value = availableCovers[Math.floor(Math.random() * availableCovers.length)];
};

const triggerFileSelect = () => {
  if (fileInputRef.value) {
    fileInputRef.value.click();
  }
};

const onDragOver = () => {
  isDragging.value = true;
};

const onDragLeave = () => {
  isDragging.value = false;
};

const onDrop = (e) => {
  isDragging.value = false;
  const files = e.dataTransfer.files;
  if (files.length > 0 && files[0].type.startsWith('video/')) {
    handleFile(files[0]);
  } else {
    message.error('Please drop a valid video file.');
  }
};

const onFileChange = (e) => {
  const files = e.target.files;
  if (files.length > 0) {
    handleFile(files[0]);
  }
};

const handleFile = (file) => {
  fileName.value = file.name;
  fileSelected.value = true;
  // Automatically start simulated upload progress
  simulateUpload();
};

const simulateUpload = () => {
  uploadProgress.value = 0;
  const interval = setInterval(() => {
    if (uploadProgress.value < 100) {
      // Simulate water-like wave progress step
      uploadProgress.value += Math.floor(Math.random() * 8) + 4;
      if (uploadProgress.value > 100) uploadProgress.value = 100;
    } else {
      clearInterval(interval);
    }
  }, 120);
};

const publishVideo = () => {
  if (!isPublishReady.value) return;

  // Mixkit list of videos to randomly assign to newly uploaded ones
  const sampleVideos = [
    'https://assets.mixkit.co/videos/preview/mixkit-forest-stream-in-the-sunlight-529-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-playful-cat-lying-on-a-carpet-43286-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-typing-on-a-backlit-keyboard-in-the-dark-44026-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-cutting-vegetables-on-a-wooden-board-43026-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-woman-working-on-a-laptop-in-a-cafe-43028-large.mp4'
  ];

  const randomUrl = sampleVideos[Math.floor(Math.random() * sampleVideos.length)];

  const newVideoObj = {
    id: 'V' + Math.random().toString(36).substring(2, 6).toUpperCase(),
    cover: selectedCover.value,
    videoUrl: randomUrl,
    title: videoTitle.value,
    description: videoDesc.value,
    author: 'aixcrimson',
    time: 'Just now',
    status: 'pending',
    likes: 0,
    comments: 0,
    shares: 0,
    liked: false
  };

  emit('uploaded', newVideoObj);
  closeModal();
};
</script>

<style scoped>
.upload-modal-wrapper {
  position: fixed;
  inset: 0;
  z-index: 1000;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
}

.modal-backdrop {
  position: absolute;
  inset: 0;
  background: rgba(4, 5, 10, 0.65);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  z-index: 0;
}

.modal-container {
  position: relative;
  width: 100%;
  max-width: 720px;
  height: 540px;
  z-index: 10;
  display: flex;
  flex-direction: column;
  box-shadow: 0 32px 80px rgba(0, 0, 0, 0.5);
  border: 1px solid var(--lg-border-strong);
  border-radius: 28px;
}

.modal-content {
  display: flex;
  flex-direction: column;
  height: 100%;
  width: 100%;
}

/* Modal Header */
.modal-header {
  padding: 20px 28px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.modal-title {
  font-size: 19px;
  font-weight: 800;
  letter-spacing: -0.3px;
  color: #ffffff;
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

/* Modal Body split panel */
.modal-body {
  flex: 1;
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 24px;
  padding: 24px 28px;
  min-height: 0;
  overflow-y: auto;
}

/* Left Dropzone */
.upload-dropzone-section {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.dropzone-box {
  flex: 1;
  border: 2px dashed rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.02);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 20px;
  text-align: center;
  cursor: pointer;
  transition: all var(--lg-motion);
  box-shadow: inset 0 0 20px rgba(0, 0, 0, 0.1);
}

.dropzone-box:hover,
.dropzone-box.dragging {
  border-color: rgba(255, 255, 255, 0.6);
  background: rgba(255, 255, 255, 0.05);
  box-shadow: 0 0 24px rgba(255, 255, 255, 0.08);
}

.upload-icon {
  font-size: 44px;
  color: var(--lg-text-secondary);
  margin-bottom: 16px;
  transition: transform 0.3s ease;
}

.dropzone-box:hover .upload-icon {
  transform: translateY(-4px);
  color: var(--lg-text-primary);
}

.upload-title {
  font-weight: 700;
  font-size: 15px;
  color: var(--lg-text-primary);
  margin-bottom: 6px;
}

.upload-subtitle {
  font-size: 12px;
  color: var(--lg-text-secondary);
  margin-bottom: 16px;
}

.upload-hint {
  font-size: 10px;
  color: var(--lg-text-muted);
  line-height: 1.4;
}

/* Upload Progress block */
.upload-progress-box {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 20px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--lg-border);
  border-radius: 20px;
  padding: 16px;
  position: relative;
  overflow: hidden;
}

.video-preview-placeholder {
  position: relative;
  width: 110px;
  height: 150px;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  align-items: center;
  padding: 10px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 10px 24px rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.15);
}

.cover-card {
  position: absolute;
  inset: 0;
  background-size: cover;
  background-position: center;
  z-index: 1;
}

.cover-glow-back {
  position: absolute;
  inset: -10px;
  background-size: cover;
  background-position: center;
  filter: blur(15px);
  opacity: 0.6;
  z-index: 0;
}

.file-name {
  position: relative;
  z-index: 2;
  font-size: 11px;
  color: #fff;
  font-weight: 600;
  background: rgba(0, 0, 0, 0.65);
  backdrop-filter: blur(4px);
  padding: 3px 8px;
  border-radius: 8px;
  width: 100%;
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.liquid-progress-container {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.progress-bar-rail {
  width: 100%;
  height: 14px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 10px;
  overflow: hidden;
  position: relative;
  border: 1px solid rgba(255, 255, 255, 0.06);
}

.progress-fill {
  height: 100%;
  background: rgba(255, 255, 255, 0.85);
  border-radius: 10px;
  position: relative;
  transition: width 0.15s ease-out;
  overflow: hidden;
}

/* Water liquid wave effects inside progress bar */
.progress-fill .wave {
  position: absolute;
  right: -5px;
  top: -50%;
  width: 24px;
  height: 24px;
  background: rgba(255, 255, 255, 0.32);
  border-radius: 40%;
  animation: spinWave 2s linear infinite;
  pointer-events: none;
}

.progress-fill .wave-2 {
  background: rgba(255, 255, 255, 0.16);
  animation: spinWave 1.4s linear infinite;
  top: -60%;
}

@keyframes spinWave {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.progress-text-row {
  display: flex;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  color: var(--lg-text-secondary);
}

.upload-success-text {
  color: #22d399;
  display: flex;
  align-items: center;
  gap: 6px;
}

/* Right Details Form */
.upload-details-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-item label {
  font-size: 13px;
  font-weight: 700;
  color: var(--lg-text-secondary);
}

.form-item input,
.form-item textarea {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid var(--lg-border);
  border-radius: 12px;
  padding: 10px 14px;
  color: var(--lg-text-primary);
  outline: none;
  font-size: 14px;
  transition: all var(--lg-motion);
}

.form-item input:focus,
.form-item textarea:focus {
  border-color: rgba(255, 255, 255, 0.4);
  background: rgba(255, 255, 255, 0.08);
}

.form-item input::placeholder,
.form-item textarea::placeholder {
  color: var(--lg-text-muted);
}

.cover-selection-grid {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 8px;
}

.cover-option-card {
  aspect-ratio: 3 / 4;
  background-size: cover;
  background-position: center;
  border-radius: 8px;
  cursor: pointer;
  position: relative;
  border: 1.5px solid transparent;
  transition: all var(--lg-motion);
  overflow: hidden;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
}

.cover-option-card:hover {
  transform: translateY(-2px);
  border-color: rgba(255, 255, 255, 0.4);
}

.cover-option-card.active {
  border-color: #ffffff;
  box-shadow: 0 0 12px rgba(255, 255, 255, 0.25);
}

.selected-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ffffff;
  font-size: 18px;
}

/* Modal Footer */
.modal-footer {
  padding: 16px 28px;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(14, 18, 30, 0.3);
}

.cancel-btn,
.publish-btn {
  height: 40px;
  padding: 0 24px;
  border-radius: 12px;
  font-weight: 700;
  font-size: 14px;
  cursor: pointer;
  transition: all var(--lg-motion);
  border: 1px solid var(--lg-border);
}

.cancel-btn {
  background: rgba(255, 255, 255, 0.06);
  color: var(--lg-text-secondary);
}

.cancel-btn:hover {
  background: rgba(255, 255, 255, 0.12);
  color: var(--lg-text-primary);
}

.publish-btn {
  background: rgba(255, 255, 255, 0.95);
  color: #08090d;
  border-color: rgba(255, 255, 255, 0.8);
}

.publish-btn:hover:not(:disabled) {
  filter: brightness(1.1);
  transform: translateY(-1px);
}

.publish-btn:disabled {
  background: var(--lg-surface-soft);
  border-color: rgba(255, 255, 255, 0.05);
  color: var(--lg-text-muted);
  box-shadow: none;
  cursor: not-allowed;
}

/* Responsiveness overrides */
@media (max-width: 720px) {
  .modal-container {
    height: 90vh;
    border-radius: 24px;
  }

  .modal-body {
    grid-template-columns: 1fr;
    gap: 20px;
    padding: 16px 20px;
  }

  .upload-dropzone-section {
    height: 180px;
  }

  .cover-selection-grid {
    grid-template-columns: repeat(5, minmax(0, 1fr));
  }
}
</style>
