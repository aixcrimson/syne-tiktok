<template>
  <div class="comments-page">
    <div class="header-actions glass-toolbar">
      <h2>Comment Management</h2>
      <a-input-search
        placeholder="Search comments or users"
        class="glass-search"
        size="large"
      />
    </div>

    <div class="comments-list">
      <a-empty description="Comment management module under construction" />
    </div>
  </div>
</template>

<style scoped>
.comments-page {
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

.glass-toolbar,
.comments-list {
  border: 1px solid var(--lg-border);
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.12), rgba(255, 255, 255, 0.04));
  box-shadow: 0 18px 56px rgba(0, 0, 0, 0.28), inset 0 1px 0 rgba(255, 255, 255, 0.2);
  backdrop-filter: var(--lg-blur-soft);
  -webkit-backdrop-filter: var(--lg-blur-soft);
}

.glass-toolbar {
  padding: 14px;
  border-radius: 24px;
}

.glass-search {
  width: min(360px, 100%);
}

h2 {
  color: var(--lg-text-primary);
  margin: 0;
  letter-spacing: -0.03em;
}

.comments-list {
  border-radius: 28px;
  padding: 48px;
  min-height: 400px;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  overflow: hidden;
}

.comments-list::before {
  content: '';
  position: absolute;
  width: 280px;
  height: 280px;
  border-radius: 999px;
  background: radial-gradient(circle, rgba(102, 217, 255, 0.18), transparent 64%);
  top: -90px;
  right: -70px;
}

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

:deep(.ant-empty) {
  position: relative;
  z-index: 1;
}

:deep(.ant-empty-description) {
  color: var(--lg-text-secondary);
}

@media (max-width: 720px) {
  .header-actions {
    align-items: stretch;
  }

  .glass-search {
    width: 100%;
  }

  .comments-list {
    padding: 32px 18px;
  }
}
</style>
