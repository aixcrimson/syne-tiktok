<template>
  <div class="comments-page">
    <div class="header-actions">
      <h2>Comment Management</h2>
      <a-input-search
        placeholder="Search comments or users"
        style="width: 300px"
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
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

h2 {
  color: white;
  margin: 0;
}

.comments-list {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 40px;
  min-height: 400px;
  display: flex;
  justify-content: center;
  align-items: center;
  border: 1px solid rgba(255, 255, 255, 0.05);
}

:deep(.ant-empty-description) {
  color: rgba(255, 255, 255, 0.5);
}
</style>
