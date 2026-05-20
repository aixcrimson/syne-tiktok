<template>
  <div class="audit-page">
    <div class="header-actions glass-toolbar">
      <a-input-search
        v-model:value="searchText"
        placeholder="Search videos by title or author"
        class="glass-search"
        @search="onSearch"
        size="large"
      />
      <a-radio-group v-model:value="statusFilter" button-style="solid" size="large" class="glass-filter">
        <a-radio-button value="all">All</a-radio-button>
        <a-radio-button value="pending">Pending</a-radio-button>
        <a-radio-button value="approved">Approved</a-radio-button>
        <a-radio-button value="rejected">Rejected</a-radio-button>
      </a-radio-group>
    </div>

    <div class="table-shell">
      <a-table
        :columns="columns"
        :data-source="filteredData"
        class="glass-table"
        :pagination="{ pageSize: 8 }"
        :scroll="{ x: 'max-content' }"
      >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'cover'">
          <div class="video-cover" :style="{ backgroundImage: `url(${record.cover})` }" @click="playVideo(record)">
            <div class="play-icon"><PlayCircleOutlined /></div>
          </div>
        </template>
        <template v-else-if="column.key === 'status'">
          <a-tag :color="getStatusColor(record.status)">
            {{ record.status.toUpperCase() }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space v-if="record.status === 'pending'">
            <a-button type="primary" size="small" @click="handleApprove(record)">Approve</a-button>
            <a-button danger size="small" @click="handleReject(record)">Reject</a-button>
          </a-space>
          <div v-else class="action-status-completed">
            <template v-if="record.status === 'approved'">
              <span class="status-badge approved">
                <CheckCircleFilled class="status-icon" /> Approved
              </span>
            </template>
            <template v-else-if="record.status === 'rejected'">
              <span class="status-badge rejected">
                <CloseCircleFilled class="status-icon" /> Rejected
              </span>
            </template>
          </div>
        </template>
      </template>
      </a-table>
    </div>

    <!-- 视频播放弹窗 -->
    <a-modal
      v-model:open="isPlayModalVisible"
      :title="currentVideo?.title || '视频预览'"
      :footer="null"
      destroyOnClose
      centered
      width="800px"
      wrapClassName="glass-modal-wrap"
    >
      <div class="video-player-container">
        <video
          v-if="currentVideo?.videoUrl"
          :src="currentVideo.videoUrl"
          controls
          autoplay
          class="video-element"
        ></video>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { PlayCircleOutlined, CheckCircleFilled, CloseCircleFilled } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const searchText = ref('');
const statusFilter = ref('pending');
const isPlayModalVisible = ref(false);
const currentVideo = ref(null);

const playVideo = (record) => {
  currentVideo.value = record;
  isPlayModalVisible.value = true;
};

const columns = [
  { title: 'ID', dataIndex: 'id', key: 'id', width: '80px' },
  { title: 'Cover', dataIndex: 'cover', key: 'cover', width: '120px' },
  { title: 'Title', dataIndex: 'title', key: 'title' },
  { title: 'Author', dataIndex: 'author', key: 'author' },
  { title: 'Upload Time', dataIndex: 'time', key: 'time' },
  { title: 'Status', dataIndex: 'status', key: 'status', width: '100px' },
  { title: 'Action', key: 'action', width: '180px' },
];

const mockData = ref([
  { id: 'V001', cover: 'https://picsum.photos/id/10/200/300', videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-forest-stream-in-the-sunlight-529-large.mp4', title: 'Amazing Nature Scenery', author: 'nature_lover', time: '2026-05-18 10:00', status: 'pending' },
  { id: 'V002', cover: 'https://picsum.photos/id/20/200/300', videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-playful-cat-lying-on-a-carpet-43286-large.mp4', title: 'Funny Cat Compilation', author: 'cat_memes', time: '2026-05-18 09:30', status: 'approved' },
  { id: 'V003', cover: 'https://picsum.photos/id/30/200/300', videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-typing-on-a-backlit-keyboard-in-the-dark-44026-large.mp4', title: 'How to code in Vue 3', author: 'dev_guru', time: '2026-05-18 08:15', status: 'pending' },
  { id: 'V004', cover: 'https://picsum.photos/id/40/200/300', videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-cutting-vegetables-on-a-wooden-board-43026-large.mp4', title: 'Street Food Tour', author: 'foodie', time: '2026-05-17 22:40', status: 'rejected' },
  { id: 'V005', cover: 'https://picsum.photos/id/50/200/300', videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-woman-working-on-a-laptop-in-a-cafe-43028-large.mp4', title: 'Liquid Glass Tutorial', author: 'ui_designer', time: '2026-05-17 15:20', status: 'pending' },
]);

const filteredData = computed(() => {
  return mockData.value.filter(item => {
    const matchStatus = statusFilter.value === 'all' || item.status === statusFilter.value;
    const matchSearch = item.title.toLowerCase().includes(searchText.value.toLowerCase()) || 
                        item.author.toLowerCase().includes(searchText.value.toLowerCase());
    return matchStatus && matchSearch;
  });
});

const getStatusColor = (status) => {
  switch(status) {
    case 'approved': return 'success';
    case 'rejected': return 'error';
    case 'pending': return 'warning';
    default: return 'default';
  }
};

const handleApprove = (record) => {
  record.status = 'approved';
  message.success(`Video ${record.id} approved`);
};

const handleReject = (record) => {
  record.status = 'rejected';
  message.error(`Video ${record.id} rejected`);
};

const onSearch = () => {
  // trigger reactivity
};
</script>

<style scoped>
.audit-page {
  display: flex;
  flex-direction: column;
  gap: 24px;
  min-width: 0;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.glass-toolbar {
  padding: 14px;
  border: 1px solid var(--lg-border);
  border-radius: 24px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.13), rgba(255, 255, 255, 0.05));
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.22), 0 16px 40px rgba(0, 0, 0, 0.2);
  backdrop-filter: var(--lg-blur-soft);
  -webkit-backdrop-filter: var(--lg-blur-soft);
}

.glass-search {
  width: min(360px, 100%);
}

.table-shell {
  border: 1px solid var(--lg-border);
  border-radius: 28px;
  overflow: hidden;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.11), rgba(255, 255, 255, 0.035));
  box-shadow: 0 20px 64px rgba(0, 0, 0, 0.32), inset 0 1px 0 rgba(255, 255, 255, 0.18);
  backdrop-filter: var(--lg-blur-soft);
  -webkit-backdrop-filter: var(--lg-blur-soft);
}

.video-cover {
  width: 80px;
  height: 120px;
  background-size: cover;
  background-position: center;
  border-radius: 16px;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  transition: transform var(--lg-motion), box-shadow var(--lg-motion), filter var(--lg-motion);
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.18);
  box-shadow: 0 10px 28px rgba(0, 0, 0, 0.28);
}

.video-cover:hover {
  filter: saturate(1.12) brightness(1.08);
  transform: scale(1.045);
  box-shadow: 0 16px 34px rgba(0, 0, 0, 0.38), 0 0 22px rgba(102, 217, 255, 0.18);
}

.play-icon {
  font-size: 24px;
  color: white;
  opacity: 0.8;
  background: rgba(255, 255, 255, 0.12);
  border-radius: 999px;
  padding: 10px;
  backdrop-filter: blur(12px);
}

/* Glass controls */
:deep(.glass-search .ant-input),
:deep(.glass-search .ant-input-group-addon),
:deep(.glass-search .ant-btn) {
  background: rgba(255, 255, 255, 0.08) !important;
  border-color: var(--lg-border) !important;
  color: var(--lg-text-primary) !important;
  box-shadow: none !important;
}

:deep(.glass-search .ant-input) {
  height: 44px;
  border-radius: 16px 0 0 16px !important;
}

:deep(.glass-search .ant-input::placeholder) {
  color: var(--lg-text-muted);
}

:deep(.glass-search .ant-btn) {
  height: 44px;
  border-radius: 0 16px 16px 0 !important;
}

:deep(.glass-filter .ant-radio-button-wrapper) {
  height: 44px;
  padding-inline: 18px;
  color: var(--lg-text-secondary);
  background: rgba(255, 255, 255, 0.07);
  border-color: var(--lg-border);
  box-shadow: none;
  transition: all var(--lg-motion);
}

:deep(.glass-filter .ant-radio-button-wrapper:hover) {
  color: var(--lg-text-primary);
  background: rgba(255, 255, 255, 0.13);
}

:deep(.glass-filter .ant-radio-button-wrapper-checked) {
  color: var(--lg-text-primary) !important;
  background: var(--lg-brand-gradient) !important;
  border-color: rgba(255, 255, 255, 0.42) !important;
  box-shadow: 0 10px 26px rgba(255, 45, 120, 0.24) !important;
}

/* Glass Table Styles Override */
:deep(.ant-table) {
  background: transparent !important;
  color: var(--lg-text-primary);
}
:deep(.ant-table-container) {
  border-radius: 26px;
}
:deep(.ant-table-thead > tr > th) {
  background: rgba(255, 255, 255, 0.13) !important;
  color: var(--lg-text-primary);
  border-bottom: 1px solid var(--lg-border);
  font-weight: 700;
}
:deep(.ant-table-tbody > tr > td) {
  color: var(--lg-text-secondary);
  background: rgba(255, 255, 255, 0.02);
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
  transition: background var(--lg-motion), color var(--lg-motion) !important;
}
:deep(.ant-table-tbody > tr:hover > td),
:deep(.ant-table-tbody > tr.ant-table-row-hover > td),
:deep(.ant-table-cell-row-hover) {
  background: rgba(255, 255, 255, 0.105) !important;
  color: var(--lg-text-primary) !important;
}
:deep(.ant-table-tbody > tr:last-child > td) {
  border-bottom-color: transparent;
}
:deep(.ant-pagination) {
  padding: 10px 16px 14px;
  margin: 0 !important;
}
:deep(.ant-pagination-item) {
  background: rgba(255, 255, 255, 0.08);
  border-color: var(--lg-border);
  border-radius: 12px;
}
:deep(.ant-pagination-item a) {
  color: var(--lg-text-primary);
}
:deep(.ant-pagination-item-active) {
  background: var(--lg-brand-gradient);
  border-color: rgba(255, 255, 255, 0.42);
}
:deep(.ant-pagination-item-link) {
  background: rgba(255, 255, 255, 0.08) !important;
  color: var(--lg-text-primary) !important;
  border-color: var(--lg-border) !important;
  border-radius: 12px !important;
}
:deep(.ant-empty-description) {
  color: var(--lg-text-muted);
}

:deep(.ant-tag) {
  border-radius: 999px;
  padding: 3px 10px;
  font-weight: 700;
  border-color: rgba(255, 255, 255, 0.2);
  background: rgba(255, 255, 255, 0.1);
}

:deep(.ant-btn) {
  border-radius: 12px;
  transition: transform var(--lg-motion), box-shadow var(--lg-motion), background var(--lg-motion);
}

:deep(.ant-btn:not([disabled]):hover) {
  transform: translateY(-1px);
}

:deep(.ant-btn-primary) {
  background: linear-gradient(135deg, #14f195, #66d9ff) !important;
  border-color: rgba(255, 255, 255, 0.28) !important;
  box-shadow: 0 10px 22px rgba(20, 241, 149, 0.18);
}

:deep(.ant-btn-dangerous) {
  background: rgba(255, 45, 120, 0.12);
  border-color: rgba(255, 45, 120, 0.4);
  color: #ff7aa8;
}

/* Action Column Completed Styles */
.action-status-completed {
  display: inline-flex;
  align-items: center;
  justify-content: flex-start;
  height: 24px;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 20px;
  backdrop-filter: blur(4px);
  user-select: none;
}

.status-badge.approved {
  color: #22d399;
  background: rgba(16, 185, 129, 0.16);
  border: 1px solid rgba(34, 211, 153, 0.36);
  box-shadow: 0 0 18px rgba(16, 185, 129, 0.22);
}

.status-badge.rejected {
  color: #ff7aa8;
  background: rgba(255, 45, 120, 0.14);
  border: 1px solid rgba(255, 45, 120, 0.34);
  box-shadow: 0 0 18px rgba(255, 45, 120, 0.2);
}

.status-icon {
  font-size: 13px;
}

/* Custom Disabled Button Styles on Dark Glass */
:deep(.ant-btn[disabled]),
:deep(.ant-btn-disabled) {
  background: var(--lg-surface-soft) !important;
  border-color: rgba(255, 255, 255, 0.1) !important;
  color: var(--lg-text-muted) !important;
  text-shadow: none !important;
  box-shadow: none !important;
  cursor: not-allowed !important;
}

/* Glass Modal Custom Styles */
:deep(.glass-modal-wrap .ant-modal-content) {
  background: rgba(11, 14, 24, 0.68) !important;
  backdrop-filter: var(--lg-blur-strong) !important;
  -webkit-backdrop-filter: var(--lg-blur-strong) !important;
  border: 1px solid var(--lg-border-strong) !important;
  border-radius: 28px !important;
  box-shadow: var(--lg-shadow-strong) !important;
  color: var(--lg-text-primary) !important;
}

:deep(.glass-modal-wrap .ant-modal-header) {
  background: transparent !important;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
  padding-bottom: 12px;
}

:deep(.glass-modal-wrap .ant-modal-title) {
  color: var(--lg-text-primary) !important;
  font-weight: 600;
  font-size: 18px;
}

:deep(.glass-modal-wrap .ant-modal-close) {
  color: var(--lg-text-secondary) !important;
}

:deep(.glass-modal-wrap .ant-modal-close:hover) {
  color: var(--lg-text-primary) !important;
  background: rgba(255, 255, 255, 0.1) !important;
}

.video-player-container {
  width: 100%;
  aspect-ratio: 16 / 9;
  border-radius: 18px;
  overflow: hidden;
  background: #000;
  margin-top: 16px;
  border: 1px solid var(--lg-border);
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.45);
}

.video-element {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

@media (max-width: 720px) {
  .header-actions {
    align-items: stretch;
  }

  .glass-search,
  .glass-filter {
    width: 100%;
  }

  :deep(.glass-filter) {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  :deep(.glass-filter .ant-radio-button-wrapper) {
    text-align: center;
    padding-inline: 10px;
  }
}
</style>
