<template>
  <div class="login-container">
    <!-- Dynamic background blobs that react with the liquid glass refraction -->
    <div class="background-blobs">
      <div class="blob blob-1"></div>
      <div class="blob blob-2"></div>
      <div class="blob blob-3"></div>
      <div class="blob blob-4"></div>
    </div>
    
    <div class="glass-wrapper">
      <!-- Highly rounded pill-like modal for iOS style -->
      <LiquidGlass borderRadius="40px" blur="25px" :opacity="0.1" :edgeRefraction="0.08" :draggable="false" :interactive="true">
        <div class="login-card">
          <!-- FaceID / Apple-style icon top -->
          <div class="login-icon-container">
            <div class="ios-icon-glow">
              <LockOutlined class="top-lock-icon" />
            </div>
          </div>
          
          <h2 class="title">Unlock Admin</h2>
          <p class="subtitle">Enter your credentials to continue</p>
          
          <a-form :model="formState" class="login-form" @finish="onFinish" layout="vertical">
            <a-form-item name="username" :rules="[{ required: true, message: 'Please input your username!' }]">
              <a-input v-model:value="formState.username" placeholder="Username" size="large" class="ios-input">
                <template #prefix><UserOutlined class="icon-color" /></template>
              </a-input>
            </a-form-item>
            
            <a-form-item name="password" :rules="[{ required: true, message: 'Please input your password!' }]">
              <a-input-password v-model:value="formState.password" placeholder="Password" size="large" class="ios-input">
                <template #prefix><LockOutlined class="icon-color" /></template>
              </a-input-password>
            </a-form-item>
            
            <a-form-item>
              <a-button type="primary" html-type="submit" size="large" block class="ios-login-btn" :loading="loading">
                Continue
              </a-button>
            </a-form-item>
          </a-form>
          
          <div class="hint">Try username: admin / password: 123456</div>
        </div>
      </LiquidGlass>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAdminStore } from '@/stores/admin';
import { UserOutlined, LockOutlined } from '@ant-design/icons-vue';
import LiquidGlass from '@/components/common/LiquidGlass.vue';
import { message } from 'ant-design-vue';

const router = useRouter();
const adminStore = useAdminStore();
const loading = ref(false);

const formState = reactive({
  username: '',
  password: '',
});

const onFinish = (values) => {
  loading.value = true;
  setTimeout(() => {
    const success = adminStore.login(values.username, values.password);
    if (success) {
      message.success({ content: 'Face ID verified', key: 'login' });
      router.push('/admin/audit');
    } else {
      message.error({ content: 'Invalid credentials', key: 'login' });
    }
    loading.value = false;
  }, 1000);
};
</script>

<style scoped>
.login-container {
  width: 100vw;
  height: 100vh;
  position: relative;
  overflow: hidden;
  background-color: #000; /* Apple style deep black background */
  display: flex;
  justify-content: center;
  align-items: center;
}

/* Background gradient blobs to show off glass refraction */
.background-blobs {
  position: absolute;
  width: 100%;
  height: 100%;
  z-index: 0;
  overflow: hidden;
  filter: blur(80px);
}

.blob {
  position: absolute;
  border-radius: 50%;
  animation: float 20s infinite alternate cubic-bezier(0.4, 0, 0.2, 1);
  opacity: 0.7;
  will-change: transform;
  transform: translateZ(0);
}

.blob-1 {
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, #ff2a5f, transparent 70%);
  top: -20%;
  left: 0%;
  animation-delay: 0s;
}

.blob-2 {
  width: 700px;
  height: 700px;
  background: radial-gradient(circle, #00d2ff, transparent 70%);
  bottom: -30%;
  right: 0%;
  animation-delay: -5s;
}

.blob-3 {
  width: 500px;
  height: 500px;
  background: radial-gradient(circle, #3a7bd5, transparent 70%);
  top: 30%;
  left: 50%;
  animation-delay: -10s;
}

.blob-4 {
  width: 400px;
  height: 400px;
  background: radial-gradient(circle, #fbc2eb, transparent 70%);
  bottom: 20%;
  left: -10%;
  animation-delay: -15s;
}

@keyframes float {
  0% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(150px, 100px) scale(1.2); }
  100% { transform: translate(-100px, 200px) scale(0.8); }
}

.glass-wrapper {
  z-index: 10;
  width: 380px;
  /* Make it slightly taller for the iOS modal look */
  min-height: 520px;
  transform: scale(1);
  transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.glass-wrapper:hover {
  transform: scale(1.02);
}

.login-card {
  width: 100%;
  height: 100%;
  padding: 40px 32px;
  display: flex;
  flex-direction: column;
  color: white;
  position: relative;
  z-index: 2;
}

.login-icon-container {
  display: flex;
  justify-content: center;
  margin-bottom: 24px;
}

.ios-icon-glow {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 0 20px rgba(255, 255, 255, 0.2), inset 0 0 10px rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.top-lock-icon {
  font-size: 28px;
  color: rgba(255, 255, 255, 0.9);
}

.title {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 8px;
  color: white;
  text-align: center;
  letter-spacing: -0.5px;
}

.subtitle {
  font-size: 15px;
  color: rgba(255, 255, 255, 0.6);
  margin-bottom: 36px;
  text-align: center;
  font-weight: 400;
}

.login-form {
  flex: 1;
}

.icon-color {
  color: rgba(255, 255, 255, 0.5);
  font-size: 18px;
}

/* iOS Input styling overrides */
:deep(.ant-form-item) {
  margin-bottom: 20px;
}

:deep(.ant-input-affix-wrapper) {
  background-color: rgba(255, 255, 255, 0.08) !important;
  border: 1px solid rgba(255, 255, 255, 0.15) !important;
  border-radius: 16px;
  padding: 12px 16px;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

:deep(.ant-input-affix-wrapper:hover), :deep(.ant-input-affix-wrapper-focused) {
  background-color: rgba(255, 255, 255, 0.12) !important;
  border-color: rgba(255, 255, 255, 0.3) !important;
  box-shadow: 0 0 0 2px rgba(255, 255, 255, 0.1), inset 0 2px 4px rgba(0, 0, 0, 0.1);
}

:deep(.ant-input) {
  background-color: transparent !important;
  color: white !important;
  font-size: 16px;
  font-weight: 500;
}

:deep(.ant-input::placeholder) {
  color: rgba(255, 255, 255, 0.4) !important;
  font-weight: 400;
}

.ios-login-btn {
  height: 52px;
  border-radius: 16px;
  background: white;
  color: black;
  border: none;
  font-weight: 600;
  font-size: 17px;
  margin-top: 10px;
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  box-shadow: 0 4px 14px rgba(255, 255, 255, 0.2);
}

.ios-login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255, 255, 255, 0.3);
  background: #f0f0f0;
}

.ios-login-btn:active {
  transform: translateY(1px);
}

.hint {
  text-align: center;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.3);
  margin-top: 24px;
  font-weight: 500;
}
</style>
