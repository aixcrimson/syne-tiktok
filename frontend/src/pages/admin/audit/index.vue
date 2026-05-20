<template>
  <div class="audit-page">
    <div class="header-actions">
      <a-input-search
        v-model:value="searchText"
        placeholder="Search videos by title or author"
        style="width: 300px"
        @search="onSearch"
        size="large"
      />
      <a-radio-group v-model:value="statusFilter" button-style="solid" size="large">
        <a-radio-button value="all">All</a-radio-button>
        <a-radio-button value="pending">Pending</a-radio-button>
        <a-radio-button value="approved">Approved</a-radio-button>
        <a-radio-button value="rejected">Rejected</a-radio-button>
      </a-radio-group>
    </div>

    <a-table 
      :columns="columns" 
      :data-source="filteredData" 
      class="glass-table"
      :pagination="{ pageSize: 8 }"
      :scroll="{ x: 'max-content' }"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'cover'">
          <div class="video-cover" :style="{ backgroundImage: `url(${record.cover})` }">
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
</template>

<script setup>
import { ref, computed } from 'vue';
import { PlayCircleOutlined, CheckCircleFilled, CloseCircleFilled } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';

const searchText = ref('');
const statusFilter = ref('pending');

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
  { id: 'V001', cover: 'https://picsum.photos/id/10/200/300', title: 'Amazing Nature Scenery', author: 'nature_lover', time: '2026-05-18 10:00', status: 'pending' },
  { id: 'V002', cover: 'https://picsum.photos/id/20/200/300', title: 'Funny Cat Compilation', author: 'cat_memes', time: '2026-05-18 09:30', status: 'approved' },
  { id: 'V003', cover: 'https://picsum.photos/id/30/200/300', title: 'How to code in Vue 3', author: 'dev_guru', time: '2026-05-18 08:15', status: 'pending' },
  { id: 'V004', cover: 'https://picsum.photos/id/40/200/300', title: 'Street Food Tour', author: 'foodie', time: '2026-05-17 22:40', status: 'rejected' },
  { id: 'V005', cover: 'https://picsum.photos/id/50/200/300', title: 'Liquid Glass Tutorial', author: 'ui_designer', time: '2026-05-17 15:20', status: 'pending' },
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
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.video-cover {
  width: 80px;
  height: 120px;
  background-size: cover;
  background-position: center;
  border-radius: 8px;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  transition: transform 0.2s;
}

.video-cover:hover {
  transform: scale(1.05);
}

.play-icon {
  font-size: 24px;
  color: white;
  opacity: 0.8;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
}

/* Glass Table Styles Override */
:deep(.ant-table) {
  background: transparent !important;
  color: white;
}
:deep(.ant-table-thead > tr > th) {
  background: rgba(255, 255, 255, 0.1) !important;
  color: white;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}
:deep(.ant-table-tbody > tr > td) {
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  transition: background 0.15s ease !important;
}
:deep(.ant-table-tbody > tr:hover > td),
:deep(.ant-table-tbody > tr.ant-table-row-hover > td),
:deep(.ant-table-cell-row-hover) {
  background: rgba(255, 255, 255, 0.05) !important;
}
:deep(.ant-pagination-item) {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.2);
}
:deep(.ant-pagination-item a) {
  color: white;
}
:deep(.ant-pagination-item-active) {
  background: #ff0050;
  border-color: #ff0050;
}
:deep(.ant-pagination-item-link) {
  background: rgba(255, 255, 255, 0.1) !important;
  color: white !important;
  border-color: rgba(255, 255, 255, 0.2) !important;
}
:deep(.ant-empty-description) {
  color: rgba(255, 255, 255, 0.5);
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
  color: #10b981;
  background: rgba(16, 185, 129, 0.15);
  border: 1px solid rgba(16, 185, 129, 0.3);
  box-shadow: 0 0 12px rgba(16, 185, 129, 0.2);
}

.status-badge.rejected {
  color: #ef4444;
  background: rgba(239, 68, 68, 0.15);
  border: 1px solid rgba(239, 68, 68, 0.3);
  box-shadow: 0 0 12px rgba(239, 68, 68, 0.2);
}

.status-icon {
  font-size: 13px;
}

/* Custom Disabled Button Styles on Dark Glass */
:deep(.ant-btn[disabled]),
:deep(.ant-btn-disabled) {
  background: rgba(255, 255, 255, 0.04) !important;
  border-color: rgba(255, 255, 255, 0.08) !important;
  color: rgba(255, 255, 255, 0.2) !important;
  text-shadow: none !important;
  box-shadow: none !important;
  cursor: not-allowed !important;
}
</style>
